<%inherit file="/base.mako" />
<%namespace name="lib" file="/lib.mako"/>
<%namespace name="dexlib" file="/pokedex/lib.mako"/>

<%def name="title()">Stat calculator</%def>

<%def name="title_in_page()">
<ul id="breadcrumbs">
    <li><a href="${url('/dex')}">Pokédex</a></li>
    <li>Gadgets</li>
    <li>Stat calculator</li>
</ul>
</%def>

<p>WHIRLWIND EXPLANATION: Pokémon have a fixed, permanent score from 0 to 31 for each stat that affects how good that stat can ever get.</p>
<p>This calculator will figure out that score (called a "gene" or, more obtusely, an "IV") for you, so you can discard the <em>unworthy</em>.  It's more accurate for higher-level Pokémon, so it's helpful to go into a level 100 wifi battle with someone and check your Pokémon's stats from there.</p>

<h1>Stat calculator</h1>

${h.form(url.current(), method=u'GET')}
<dl class="standard-form">
    ${lib.field(u'pokemon')}
    ${lib.field(u'level', size=3)}
    ${lib.field(u'nature')}
</dl>

<table class="dex-stat-calculator striped-row-groups">
<col class="dex-col-stat-calc-labels">
<colgroup>
    % for stat in c.stats:
    <col class="dex-col-stat-calc">
    % endfor
</colgroup>
<thead>
    % if c.form.nature.data and not c.form.nature.data.is_neutral:
    <tr>
        <th></th>
        % for stat in c.stats:
        % if c.form.nature.data.increased_stat == stat:
        <th class="dex-nature-buff">+10%</th>
        % elif c.form.nature.data.decreased_stat == stat:
        <th class="dex-nature-nerf">&minus;10%</th>
        % else:
        <th></th>
        % endif
        % endfor
    </tr>
    % endif
    <tr class="header-row">
        <th></th>
        % for stat in c.stats:
        <th>${stat.name}</th>
        % endfor
    </tr>
</thead>
<tbody>
    % if not c.results:
    <tr>
        <th></th>
        <td colspan="${len(c.stats)}" class="protip">
            Your Pokémon's actual stats, from the Summary screen in-game.
        </td>
    </tr>
    % endif
    <tr>
        <th>Stats</th>
        % for field_name in c.stat_fields:
        <td>${lib.bare_field(field_name, size=3)}</td>
        % endfor
    </tr>

    % if c.results:
    <tr>
        <th>Possible range</th>
        % for stat in c.stats:
        <td
            % if c.form.nature.data.is_neutral:
            <% pass %>\
            % elif c.form.nature.data.increased_stat == stat:
            class="dex-nature-buff"
            % elif c.form.nature.data.decreased_stat == stat:
            class="dex-nature-nerf"
            % endif
        >
            % if len(set(c.valid_range[stat])) == 1:
            ${c.valid_range[stat][0]}
            % else:
            ${c.valid_range[stat][0]}–${c.valid_range[stat][1]}
            % endif
        </td>
        % endfor
    </tr>
    % endif
</tbody>
<tbody>
    % if not c.results:
    <tr>
        <th></th>
        <td colspan="${len(c.stats)}" class="protip">
            Accumulated as your Pokémon battles. <br>
            If you don't know what this is, and your Pokémon has EVER battled or eaten a vitamin, this calculator CANNOT work.  Using Rare Candy is okay, though.
        </td>
    </tr>
    % endif
    <tr>
        <th>Effort</th>
        % for field_name in c.effort_fields:
        <td>${lib.bare_field(field_name, size=3)}</td>
        % endfor
    </tr>
</tbody>
% if c.results:
<tbody>
    % if 0:
    <tr>
        <th></th>
        <td colspan="${len(c.stats)}" class="protip">
            Your Pokémon's awesome-ness for each stat, from 0 to 31.
        </td>
    </tr>
    % endif
    <tr>
        <th>Genes (IVs)</th>
        % for stat in c.stats:
        <td>
            % if c.results[stat]:
            ${c.results[stat]}
            % else:
            <span class="impossible">impossible</span>
            % endif
        </td>
        % endfor
    </tr>
    <tr>
        ## Pretty graphs!
        <th></th>
        % for stat in c.stats:
        <td>
            % if c.results[stat]:
            <div class="dex-stat-vertical-graph">
            % for gene in xrange(31, -1, -1):
                % if gene in c.valid_genes[stat]:
                <div class="point" style="background: ${c.stat_graph_chunk_color(gene)};"></div>
                % else:
                <div class="pointless"></div>
                % endif
            % endfor
            </div>
            % endif
        </td>
        % endfor
    </tr>
    <tr>
        <td colspan="${len(c.stats) + 1}">
            % if all(c.results.values()):
            <p>And for your copy/pasting pleasure:</p>
            <p class="clipboard">
                ${c.results[c.stats[0]]} HP;
                ${c.results[c.stats[1]]}/${c.results[c.stats[2]]} Physical;
                ${c.results[c.stats[3]]}/${c.results[c.stats[4]]} Special;
                ${c.results[c.stats[5]]} Speed
            </p>
            % else:
            <p>Uh-oh.  The set of stats you gave is totally impossible. Better double-check against your game.</p>
            <p>The most common problem is effort; if a Pokémon has been trained at all, it'll have some effort accumulated.  This affects its stats, and there's no way to know how much effort it has unless you've been keeping track.  Sorry.</p>
            <p>If you're desperate, you could try the effort-lowering berries (Pomeg et al.), which will reduce effort in a given stat by 10 at a time.  Drop every stat's effort until it won't drop any further, then try again.</p>
            % endif
        </td>
    </tr>
</tbody>
% endif
</table>

<p><button type="submit">Let's do this!</button></p>
<p>
    <button type="reset">Reset</button> or
    <a href="${url.current()}"><img src="${h.static_uri('spline', 'icons/eraser.png')}" alt=""> start over</a>
</p>
${h.end_form()}
