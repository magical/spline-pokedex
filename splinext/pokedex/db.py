# encoding: utf8
"""Small wrapper for access to the pokedex library's database."""
from __future__ import absolute_import

import os.path
import re

import pokedex.db
import pokedex.db.tables as t
from pokedex.db import ENGLISH_ID
from pokedex.db.multilang import MultilangScopedSession, MultilangSession
import pokedex.lookup

import sqlalchemy as sqla
from sqlalchemy import orm
from sqlalchemy.sql import func
from zope.sqlalchemy import ZopeTransactionExtension

# stolen from veekun-pokedex
pokedex_session = MultilangScopedSession(
    orm.sessionmaker(
        class_=MultilangSession,
        extension=ZopeTransactionExtension(),
        default_language_id=ENGLISH_ID,
    )
)

pokedex_lookup = None

def connect(settings):
    """Instantiates the `pokedex_session` and `pokedex_lookup` objects."""
    # DB session for everyone to use.
    engine = sqla.engine_from_config(settings, 'spline-pokedex.sqlalchemy.')
    pokedex_session.configure(bind=engine)

    # Lookup object
    global pokedex_lookup
    lookup_directory = settings['spline-pokedex.lookup_directory']
    pokedex_lookup = pokedex.lookup.PokedexLookup(
        # Keep our own whoosh index in the /data dir
        directory=lookup_directory,
        session=pokedex_session,
    )
    if not pokedex_lookup.index:
        pokedex_lookup.rebuild_index()


# Quick access to a few database objects
def get_by_identifier_query(table, identifier):
    """Returns a query to find a single row in the given table by identifier.

    Don't use this for Pokémon!  Use `pokemon_identifier_query()`,
    as it knows about forms.
    """

    identifier = identifier.lower()
    identifier = re.sub(u'[ _]+', u'-', identifier)
    identifier = re.sub(u'[\'.]', u'', identifier)

    query = pokedex_session.query(table).filter(
                table.identifier == identifier)

    return query

def pokemon_form_identifier_query(identifier, form_identifier=None):
    """Returns a query that will look for the Pokémon with the given identifier.
    """

    q = get_by_identifier_query(t.PokemonForm, form_identifier)
    q = q.join(t.PokemonForm.species)
    q = q.filter(t.Pokemon.forms.any())

    if form:
        # If a form has been specified, it must match
        q = q.join(t.Pokemon.unique_form) \
            .filter(t.PokemonForm.identifier == form)
    else:
        # If there's NOT a form, just make sure we get a form base Pokémon
        # TODO wtf is this any() for?
        q = q.filter(t.Pokemon.forms.any())

    return q

def get_by_name_query(table, name, query=None):
    """Returns a query to find a single row in the given table by name,
    ignoring case.

    Don't use this for Pokémon!  Use `pokemon_query()`, as it knows about
    forms.

    If query is given, it will be extended joined with table.name_table,
    otherwise table will be queried.
    """

    name = name.lower()

    if query is None:
        query = pokedex_session.query(table)

    query = query.join(table.names_local) \
        .filter(func.lower(table.names_table.name) == name)

    return query

def pokemon_query(name, form=None):
    """Returns a query that will look for the named Pokémon.

    form, if given, is a form identifier.
    """

    query = pokedex_session.query(t.Pokemon)
    query = query.join(t.Pokemon.species)
    query = query.join(t.PokemonSpecies.names_local)
    query = query.filter(func.lower(t.PokemonSpecies.names_table.name) == name.lower())

    if form:
        # If a form has been specified, it must match
        query = query.join(t.Pokemon.forms) \
            .filter(t.PokemonForm.form_identifier == form)
    else:
        # If there's NOT a form, just make sure we get a default Pokémon
        query = query.filter(t.Pokemon.is_default == True)

    return query

def pokemon_form_query(name, form=None):
    """Returns a query that will look for the specified Pokémon form, or the
    default form of the named Pokémon.
    """

    q = pokedex_session.query(t.PokemonForm)
    q = q.join(t.PokemonForm.pokemon)
    q = q.join(t.Pokemon.species)
    q = q.join(t.PokemonSpecies.names_local) \
        .filter(func.lower(t.PokemonSpecies.names_table.name) == name.lower())

    if form:
        # If a form has been specified, it must match
        q = q.filter(t.PokemonForm.form_identifier == form)
    else:
        # If there's NOT a form, just get the default form
        q = q.filter(t.Pokemon.is_default == True)
        q = q.filter(t.PokemonForm.is_default == True)

    return q

def generation(id):
    return pokedex_session.query(t.Generation).get(id)
def version(name):
    return pokedex_session.query(t.Version).filter_by(name=name).one()
