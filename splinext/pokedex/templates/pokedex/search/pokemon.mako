<%inherit file="/base.mako"/>
<%namespace name="lib" file="/lib.mako"/>
<%namespace name="dexlib" file="/pokedex/lib.mako"/>

<%def name="title()">Pokémon Search</%def>

### RESULTS ###
## Four possibilities here: the form wasn't submitted, the form was submitted
## but was bogus, the form was submitted and there are no results, or the form
## was submitted and is good.

% if c.form.was_submitted:
<h1>Results</h1>
<p><a href="${url.current()}"><img src="${h.static_uri('spline', 'icons/eraser.png')}" alt=""> Start over</a></p>

% if not c.form.is_valid:
## Errors
<p>It seems you entered something bogus for:</p>
<ul class="classic-list">
    % for field_name in c.form.errors.keys():
    <li>${c.form[field_name].label.text}</li>
    % endfor
</ul>

% elif c.form.is_valid and not c.results:
## No results
<p>Nothing found.</p>

% elif c.form.is_valid:
## Got something

## Display.  Could be one of several options...
% if c.display_mode == 'custom-table':
## Some sort of table.  (Standard table is also done this way.)
## These defs are all at the bottom of this file
<table class="dex-pokemon-moves striped-rows">
% for column in c.display_columns:
${getattr(self, 'col_' + column)()}
% endfor
<tr class="header-row">
    % for column in c.display_columns:
    ${getattr(self, 'th_' + column)()}
    % endfor
</tr>

<%
    evolution_chain_stack = []
    last_evolution_chain_id = None
%>\
% for result in c.results:
    <%
        tr_classes = []
        if c.original_results is not None:
            # Evolution chain sorting.
            # Need to make the indenting right, and take care of fake results

            # Indenting is kept right by keeping a running list of this
            # Pokémon's ancestry.  Luckily, except for babies, National Dex
            # order is always post-order
            if last_evolution_chain_id == result.evolution_chain_id:
                # Still in the same family.  Look for this Pokémon's immediate
                # parent somewhere in the stack, in case this is a sibling.
                # Yes, this will die if the parent hasn't been seen
                while evolution_chain_stack[-1] != \
                    result.evolution_parent_pokemon_id:

                    evolution_chain_stack.pop()

            else:
                # New family; reset everything and show a divider
                if result.is_baby:
                    evolution_chain_stack = []
                else:
                    # Stub out a baby
                    evolution_chain_stack = [None]

                if last_evolution_chain_id is not None:
                    tr_classes.append(u'chain-divider')
                last_evolution_chain_id = result.evolution_chain_id

            # nb: babies are depth zero
            tr_classes.append(
                u"evolution-depth-{0}".format(len(evolution_chain_stack))
            )

            if result.id not in c.original_results:
                # Fake!
                tr_classes.append(u'fake-result')

            evolution_chain_stack.append(result.id)
    %>\

    <tr class="${u' '.join(tr_classes)}">
        % for column in c.display_columns:
        ${getattr(self, 'td_' + column)(result)}
        % endfor
    </tr>
% endfor
</table>

% elif c.display_mode == 'custom-list-bullets':
## Plain bulleted list with a Template.
<ul class="classic-list">
    % for result in c.results:
    <li>${h.pokedex.pokemon_link(result, h.pokedex.apply_pokemon_template(c.display_template, result))}</li>
    % endfor
</ul>

% elif c.display_mode == 'custom-list':
## Plain unbulleted list with a Template.  Less semantic HTML, but more
## friendly to clipboards.
<div class="dex-pokemon-search-list">
% for result in c.results:
${h.pokedex.pokemon_link(result, h.pokedex.apply_pokemon_template(c.display_template, result))}<br>
% endfor
</div>

% elif c.display_mode == 'icons':
## Grid of icons
<ul class="inline">
    % for result in c.results:
    <li>${h.pokedex.pokemon_link(result, h.pokedex.pokemon_sprite(result, prefix=u'icons'), class_='dex-icon-link')}</li>
    % endfor
</ul>

% elif c.display_mode == 'sprites':
## Grid of most recent sprites
<ul class="inline">
    % for result in c.results:
    <li>${h.pokedex.pokemon_link(result, h.pokedex.pokemon_sprite(result), class_='dex-icon-link')}</li>
    % endfor
</ul>

% endif  ## display_mode

% endif  ## search performed
% endif  ## form submitted


### SEARCH FORM ###

<h1>Pokémon Search</h1>
${h.form(url.current(), method='GET')}
<p>Unless otherwise specified: matching Pokémon must match ALL of the criteria, but can match ANY selections within a group (e.g., evolution stage).</p>
<p>Anything left blank is ignored entirely.</p>

<div class="dex-column-container">
<div class="dex-column-2x">
    <h2>Essentials</h2>
    <dl class="standard-form">
        ${lib.field('name')}
        ${lib.field('ability')}
        ${lib.field('held_item')}
        ${lib.field('growth_rate')}
        <dt>${c.form.gender_rate.label() | n}</dt>
        <dd>${c.form.gender_rate_operator() | n} ${c.form.gender_rate() | n}</dd>
        <dt>${c.form.egg_group.label() | n}</dt>
        <dd>
            ${c.form.egg_group_operator() | n}
            % for widget in c.form.egg_group:
            ${widget() | n}
            % endfor
        </dd>
    </dl>
</div>
<div class="dex-column">
    <h2>Flavor</h2>
    <dl class="standard-form">
        ${lib.field('species')}
        ${lib.field('color')}
        ${lib.field('habitat')}
        ${lib.field('shape')}
    </dl>
</div>
</div>

<h2>Type</h2>
<p>Type must be ${c.form.type_operator() | n}.</p>
% for error in c.form.type_operator.errors:
<p class="error">${error}</p>
% endfor
<ul class="dex-type-list">
    ## always sort ??? last
    % for a_field in sorted(c.form.type, key=lambda field: field.label.text):
    <li> <label>
        ${h.pokedex.type_icon(a_field.label.text)}
        ${a_field() | n}
    </label> </li>
    % endfor
</ul>
% for error in c.form.type.errors:
<p class="error">${error}</p>
% endfor

<h2>Evolution</h2>
<div class="dex-column-container">
<div class="dex-column">
    <dl class="standard-form">
        ${lib.field('evolution_stage')}
    </dl>
</div>
<div class="dex-column">
    <dl class="standard-form">
        ${lib.field('evolution_position')}
    </dl>
</div>
<div class="dex-column">
    <dl class="standard-form">
        ${lib.field('evolution_special')}
    </dl>
</div>
</div>

<h2>Generation</h2>
<div class="dex-column-container">
<div class="dex-column">
    <dl class="standard-form">
        ${lib.field('introduced_in')}
    </dl>
</div>
<div class="dex-column-2x">
    <dl class="standard-form">
        ${lib.field('in_pokedex')}
    </dl>
</div>
</div>

<h2>Numbers</h2>
<p>Understands single numbers (<code>50</code>); ranges (<code>17-29</code>); at-least (<code>100+</code>); at-most (<code>&lt; 100</code>); approximations (<code>120~10</code> = <code>110-130</code>); and any combination of those (<code>20, 50-60, 90~5</code>).</p>
<p>Height and weight work the same way, but require units.  Anything is acceptable.</p>

<div class="dex-column-container">
<div class="dex-column">
    <h3>Base stats</h3>
    <dl class="standard-form">
        % for stat_id, field_name in c.stat_fields:
        ${lib.field('stat_' + field_name)}
        % endfor
    </dl>
</div>
<div class="dex-column">
    <h3>Effort</h3>
    <dl class="standard-form">
        % for stat_id, field_name in c.stat_fields:
        ${lib.field('effort_' + field_name)}
        % endfor
    </dl>
</div>
<div class="dex-column">
    <h3>Breeding/Training</h3>
    <dl class="standard-form">
        ${lib.field('steps_to_hatch')}
        ${lib.field('base_experience')}
        ${lib.field('capture_rate')}
        ${lib.field('base_happiness')}
    </dl>
    <h3>Size</h3>
    <dl class="standard-form">
        ${lib.field('height')}
        ${lib.field('weight')}
    </dl>
</div>
</div>

<h2>Moves</h2>
<div class="dex-column-container">
<div class="dex-column">
    <h3>Moves</h3>
    <p>Look for: ${lib.bare_field('move_fuzz')}</p>
    ## Render move fields manually; don't want the labels
    <ul>
        % for field in c.form.move:
        <li>
            ${field(class_='js-dex-suggest js-dex-suggest-move') | n}
            % for error in field.errors:
            <p class="error">${error}</p>
            % endfor
        </li>
        % endfor
    </ul>
</div>
<div class="dex-column">
    <h3>Learned by</h3>
    ${lib.bare_field('move_method')}
</div>
<div class="dex-column">
    <h3>Version</h3>
    ## Arrange versions by generation

    <% version_group_controls = dict((control.data, control)
        for control in c.form.move_version_group) %>\
    <table id="dex-pokemon-search-move-versions">
        % for generation in c.generations:
        <tr>
            % for version_group in generation.version_groups:
            <td>
                ${version_group_controls[ unicode(version_group.id) ]()}
                ${version_group_controls[ unicode(version_group.id) ].label()}
            </td>
            % endfor
        </tr>
        % endfor
    </table>

    % for error in c.form.move_version_group.errors:
    <p class="error">${error}</p>
    % endfor
</div>
</div>

<h2>Display and sorting</h2>
<div class="dex-column-container">
<div class="dex-column">
    <dl class="standard-form">
        ${lib.field('display')}
        ${lib.field('sort')}
        ${lib.field('sort_backwards')}
    </dl>
</div>
<div class="dex-column-2x">
    <h3>${c.form.column.label() | n}</h3>
    ${lib.bare_field('column')}
</div>
<div class="dex-column-2x">
    <h3>${c.form.format.label() | n}</h3>
    ${lib.bare_field('format')}

    <h3>Format</h3>
    <p>e.g.: <code>* $id $name</code> becomes <code>&bull; 133 Eevee</code></p>
    <dl class="standard-form">
        <dt><code>*</code></dt>
        <dd>&bull;</dd>

        % for pattern in ( \
            '$icon', '$id', '$name', '$gender', \
            '$type', '$type1', '$type2', \
            '$ability', '$ability1', '$ability2', \
            '$egg_group', '$egg_group1', '$egg_group2', \
            '$effort', '$stats', \
            '$hp', '$attack', '$defense', \
            '$special_attack', '$special_defense', '$speed', \
            '$height', '$height_ft', '$height_m', \
            '$weight', '$weight_lb', '$weight_kg', \
            '$species', '$color', '$habitat', '$shape', \
            '$steps_to_hatch', '$base_experience', '$capture_rate', '$base_happiness', \
        ):
        <%! from string import Template %>\
        <% template = Template(pattern) %>\
        <dt><code>${pattern}</code></dt>
        <dd>${h.pokedex.apply_pokemon_template(template, c.eevee)}</dd>
        % endfor
    </dl>
</div>
</div>

<p>
    ## Always shorten when the form is submitted!
    ${c.form.shorten(value=1) | n}
    <button type="submit">Search</button>
    <button type="reset">Reset form</button>
</p>
${h.end_form()}





### Display columns defs
<%def name="col_id()"><col class="dex-col-id"></%def>
<%def name="th_id()"><th>Num</th></%def>
<%def name="td_id(pokemon)"><td>${pokemon.national_id}</td></%def>

<%def name="col_icon()"><col class="dex-col-icon"></%def>
<%def name="th_icon()"><th></th></%def>
<%def name="td_icon(pokemon)"><td class="icon">${h.pokedex.pokemon_sprite(pokemon, prefix='icons')}</td></%def>

<%def name="col_name()"><col class="dex-col-name"></%def>
<%def name="th_name()"><th>Name</th></%def>
<%def name="td_name(pokemon)"><td class="name">${h.pokedex.pokemon_link(pokemon, pokemon.full_name)}</td></%def>

<%def name="col_growth_rate()"><col class="dex-col-max-exp"></%def>
<%def name="th_growth_rate()"><th>EXP to L100</th></%def>
<%def name="td_growth_rate(pokemon)"><td class="max-exp">${pokemon.evolution_chain.growth_rate.max_experience}</td></%def>

<%def name="col_type()"><col class="dex-col-type2"></%def>
<%def name="th_type()"><th>Type</th></%def>
<%def name="td_type(pokemon)">\
<td class="type2">
% for type in pokemon.types:
${h.pokedex.type_link(type)}
% endfor
</td>\
</%def>

<%def name="col_ability()"><col class="dex-col-ability"></%def>
<%def name="th_ability()"><th>Ability</th></%def>
<%def name="td_ability(pokemon)">\
<td class="ability">
% for ability in pokemon.abilities:
<a href="${url(controller='dex', action='abilities', name=ability.name.lower())}">${ability.name}</a><br>
% endfor
</td>\
</%def>

<%def name="col_gender()"><col class="dex-col-gender"></%def>
<%def name="th_gender()"><th>Gender</th></%def>
<%def name="td_gender(pokemon)"><td>${h.pokedex.pokedex_img('gender-rates/%d.png' % pokemon.gender_rate, alt=h.pokedex.gender_rate_label[pokemon.gender_rate])}</td></%def>

<%def name="col_egg_group()"><col class="dex-col-egg-group"></%def>
<%def name="th_egg_group()"><th>Egg Group</th></%def>
<%def name="td_egg_group(pokemon)">\
<td class="egg-group">
% for egg_group in pokemon.egg_groups:
${egg_group.name}<br>
% endfor
</td>
</%def>

<%def name="col_stat_hp()"><col class="dex-col-stat"></%def>
<%def name="th_stat_hp()"><th><abbr title="Hit Points">HP</abbr></th></%def>
<%def name="td_stat_hp(pokemon)"><td class="stat">${pokemon.stat('HP').base_stat}</td></%def>

<%def name="col_stat_attack()"><col class="dex-col-stat"></%def>
<%def name="th_stat_attack()"><th><abbr title="Attack">Atk</abbr></th></%def>
<%def name="td_stat_attack(pokemon)"><td class="stat">${pokemon.stat('Attack').base_stat}</td></%def>

<%def name="col_stat_defense()"><col class="dex-col-stat"></%def>
<%def name="th_stat_defense()"><th><abbr title="Defense">Def</abbr></th></%def>
<%def name="td_stat_defense(pokemon)"><td class="stat">${pokemon.stat('Defense').base_stat}</td></%def>

<%def name="col_stat_special_attack()"><col class="dex-col-stat"></%def>
<%def name="th_stat_special_attack()"><th><abbr title="Special Attack">SpA</abbr></th></%def>
<%def name="td_stat_special_attack(pokemon)"><td class="stat">${pokemon.stat('Special Attack').base_stat}</td></%def>

<%def name="col_stat_special_defense()"><col class="dex-col-stat"></%def>
<%def name="th_stat_special_defense()"><th><abbr title="Special Defense">SpD</abbr></th></%def>
<%def name="td_stat_special_defense(pokemon)"><td class="stat">${pokemon.stat('Special Defense').base_stat}</td></%def>

<%def name="col_stat_speed()"><col class="dex-col-stat"></%def>
<%def name="th_stat_speed()"><th><abbr title="Speed">Spd</abbr></th></%def>
<%def name="td_stat_speed(pokemon)"><td class="stat">${pokemon.stat('Speed').base_stat}</td></%def>

<%def name="col_stat_total()"><col class="dex-col-stat"></%def>
<%def name="th_stat_total()"><th>Total</th></%def>
<%def name="td_stat_total(pokemon)"><td class="stat">${sum((pokemon_stat.base_stat for pokemon_stat in pokemon.stats))}</td></%def>

<%def name="col_effort()"><col class="dex-col-effort"></%def>
<%def name="th_effort()"><th>Effort</th></%def>
<%def name="td_effort(pokemon)">\
<td class="effort">
% for pokemon_stat in pokemon.stats:
% if pokemon_stat.effort:
${pokemon_stat.effort} ${pokemon_stat.stat.name}<br>
% endif
% endfor
</td>\
</%def>

<%def name="col_height()"><col class="dex-col-height"></%def>
<%def name="th_height()"><th>Height</th></%def>
<%def name="td_height(pokemon)"><td class="size">${h.pokedex.format_height_imperial(pokemon.height)}</td></%def>

<%def name="col_weight()"><col class="dex-col-weight"></%def>
<%def name="th_weight()"><th>Weight</th></%def>
<%def name="td_weight(pokemon)"><td class="size">${h.pokedex.format_weight_imperial(pokemon.weight)}</td></%def>

<%def name="col_height_metric()"><col class="dex-col-height"></%def>
<%def name="th_height_metric()"><th>Height</th></%def>
<%def name="td_height_metric(pokemon)"><td class="size">${h.pokedex.format_height_metric(pokemon.height)}</td></%def>

<%def name="col_weight_metric()"><col class="dex-col-weight"></%def>
<%def name="th_weight_metric()"><th>Weight</th></%def>
<%def name="td_weight_metric(pokemon)"><td class="size">${h.pokedex.format_weight_metric(pokemon.weight)}</td></%def>

<%def name="col_species()"><col class="dex-col-species"></%def>
<%def name="th_species()"><th>Species</th></%def>
<%def name="td_species(pokemon)"><td class="species">${pokemon.species}</td></%def>

<%def name="col_color()"><col class="dex-col-color"></%def>
<%def name="th_color()"><th>Color</th></%def>
<%def name="td_color(pokemon)"><td class="color">${pokemon.color}</td></%def>

<%def name="col_habitat()"><col class="dex-col-habitat"></%def>
<%def name="th_habitat()"><th>Habitat</th></%def>
<%def name="td_habitat(pokemon)"><td class="habitat">\
% if pokemon.generation.id <= 3:
${pokemon.habitat}\
% else:
—\
% endif
</td></%def>

<%def name="col_shape()"><col class="dex-col-icon"></%def>
<%def name="th_shape()"><th>Shape</th></%def>
<%def name="td_shape(pokemon)"><td class="icon">${h.pokedex.pokedex_img('chrome/shapes/%d.png' % pokemon.shape.id, title=pokemon.shape.awesome_name, alt='')}</td></%def>

<%def name="col_steps_to_hatch()"><col class="dex-col-stat"></%def>
<%def name="th_steps_to_hatch()"><th>Steps</th></%def>
<%def name="td_steps_to_hatch(pokemon)"><td class="stat">${pokemon.evolution_chain.steps_to_hatch}</td></%def>

<%def name="col_base_experience()"><col class="dex-col-stat"></%def>
<%def name="th_base_experience()"><th>EXP</th></%def>
<%def name="td_base_experience(pokemon)"><td class="stat">${pokemon.base_experience}</td></%def>

<%def name="col_capture_rate()"><col class="dex-col-stat"></%def>
<%def name="th_capture_rate()"><th>Cap.</th></%def>
<%def name="td_capture_rate(pokemon)"><td class="stat">${pokemon.capture_rate}</td></%def>

<%def name="col_base_happiness()"><col class="dex-col-stat"></%def>
<%def name="th_base_happiness()"><th>:)</th></%def>
<%def name="td_base_happiness(pokemon)"><td class="stat">${pokemon.base_happiness}</td></%def>

<%def name="col_link()"><col class="dex-col-link"></%def>
<%def name="th_link()"><th></th></%def>
<%def name="td_link(pokemon)"><td>${h.pokedex.pokemon_link(pokemon, h.literal("""<img src="{0}" alt="-&gt;">""".format(h.static_uri('spline', 'icons/arrow.png'))))}</td></%def>