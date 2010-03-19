var pokedex_suggestions = {
    /*** Pokédex lookup suggestions */
    'previous_input':   "",    // don't double request the same string
    '$lookup_element':  null,  // where the dropdown box is right now
    'request':          null,  // ajax request, for canceling

    // Use a wrapper to set a small delay on the ajax request; otherwise we'll
    // ping the server after every keypress, even if the user wasn't finished
    // typing
    'timeout':         null,
    'change_wrapper': function(e) {
        // Cancel any pending request
        if (pokedex_suggestions.timeout)
            window.clearTimeout(pokedex_suggestions.timeout);

        // The actual handler will also clear this timeout
        pokedex_suggestions.timeout = window.setTimeout(
            pokedex_suggestions.change, 100, e
        );
    },

    // Handle typing in a suggestion textbox: fire off a request for matching
    // page names
    'change': function(e) {
        // Clear double-request timeout
        pokedex_suggestions.timeout = null;

        // Tab and enter aren't very useful
        if (e.keyCode == 9 || e.keyCode == 13) return;

        var $suggest_box = $('#dex-suggestions');
        var el = e.target;
        var input = el.value;

        // Don't request for the same input twice.  This happens if the user
        // pressed a navigation key, ctrl-c, overtyped a letter with the same
        // letter, etc.  If the user switched textboxes, the blur code will
        // have cleared the previous input, so having a single global is ok.
        if (input == pokedex_suggestions.previous_input) return;
        pokedex_suggestions.previous_input = input;

        // Hide the list of suggestions if there's not enough input
        if ($suggest_box.length && input.length < 2) {
            pokedex_suggestions.hide();
            return;
        }

        // Cancel any running request, or we might get a bunch of responses in
        // the wrong order
        if (pokedex_suggestions.request)
            pokedex_suggestions.request.abort();

        // Construct request URL
        var url = "/dex/suggest?prefix=" + encodeURIComponent(input);
        var type;
        if (pokedex_suggestions.$lookup_element.is(".js-dex-suggest-pokemon"))
            url += ";type=pokemon";
        else if (pokedex_suggestions.$lookup_element.is(".js-dex-suggest-move"))
            url += ";type=move";

        // Perform request, saving the request object in case we need to cancel
        // it later
        pokedex_suggestions.request = $.ajax({
            type: "GET",
            url: url,
            dataType: "json",
            error: function() {
                pokedex_suggestions.request = null;
            },
            success: function(res) {
                pokedex_suggestions.request = null;
                if (res[0] != el.value) return;

                // Clear the suggestion box
                $suggest_box.children().remove();
                $suggest_box.scrollTop(0);

                var len = input.length;
                var suggestions = res[1];
                for (var i in suggestions) {
                    var suggestion = suggestions[i];
                    var metadata = res[4][i];

                    var $suggestion_el = $('<li></li>');
                    $suggestion_el.addClass('dex-suggestion-' + metadata.type);

                    var $typed_part = $('<span class="typed"></span>')
                    $typed_part.text(suggestion.substr(0, len));

                    $suggestion_el.text(suggestion.substr(len));
                    $suggestion_el.prepend($typed_part);

                    if (metadata.image) {
                        $suggestion_el.css('background-image', "url(" + metadata.image + ")");
                    }

                    // Add country flag if not English
                    if (metadata.language && metadata.language != 'us') {
                        $suggestion_el.prepend('<img src="' + metadata.language_icon + '"'
                                             + ' alt="[' + metadata.language + ']"> ');
                    }

                    // Events
                    $suggestion_el.click(pokedex_suggestions.update_lookup);

                    $suggest_box.append($suggestion_el);
                }

                if (suggestions.length) {
                    $suggest_box.css('visibility', 'visible');
                }
                else {
                    $suggest_box.css('visibility', 'hidden');
                }

                pokedex_suggestions.move_results();
            }
        });
    },

    'update_lookup': function(e) {
        pokedex_suggestions.$lookup_element.val( $(e.target).text() );
    },

    // Handle keypresses in a suggest box.  Used to detect navigation keys and
    // move the selection within the menu as appropriate
    'keydown': function(e) {
        var $lookup = $(e.target);
        var $previous_element = pokedex_suggestions.$lookup_element;
        pokedex_suggestions.$lookup_element = $lookup;

        // If a letter was pressed it should be handled normally
        if (e.keyCode == 32 || e.keyCode >= 48)
            return;

        var $suggest_box = $('#dex-suggestions');
        if (!$suggest_box.length) return;
        var $selected = $suggest_box.find('.selected');

        // If we're using a different lookup element than before, we've gotta
        // move the result list
        if ($lookup != $previous_element) {
            pokedex_suggestions.move_results();
        }

        // Handle keypress
        if (e.keyCode == 27) {  // esc
            pokedex_suggestions.hide();
        }
        // These two cases are used for moving the selection highlight up
        // and down the fake listbox
        else if (e.keyCode == 38) {  // up
            // If the suggestion list isn't visible, show it
            if ($suggest_box.css('visibility') == "hidden") {
                $suggest_box.css('visibility', 'visible');
                return;
            }

            // Select the previous suggestion, defaulting to the last
            var $prev;
            if ($selected.length) {
                $prev = $selected.prev();
            }
            else {
                $prev = $suggest_box.children(':last-child');
            }

            $selected.removeClass('selected');
            $prev.addClass('selected');

            // Make the selection visible and prevent normal editor control
            if ($prev.length) {
                pokedex_suggestions.scroll_into_view($prev);
                e.preventDefault();
            }
        }
        else if (e.keyCode == 40) {  // down
            // If the suggestion list isn't visible, show it
            if ($suggest_box.css('visibility') == "hidden") {
                $suggest_box.css('visibility', 'visible');
                return;
            }

            // Select the next suggestion, defaulting to the first
            var $next;
            if ($selected.length) {
                $next = $selected.next();
            }
            else {
                $next = $suggest_box.children(':first-child');
            }

            $selected.removeClass('selected');
            $next.addClass('selected');

            // Make the selection visible and prevent normal editor control
            if ($next.length) {
                pokedex_suggestions.scroll_into_view($next);
                e.preventDefault();
            }
        }
        // Select the highlighted entry if there be one, otherwise submit
        else if (e.keyCode == 13) {  // enter
            // If the suggestion list isn't visible, do nothing special
            if ($suggest_box.css('visibility') == "hidden"
                || ! $selected.length)
            {
                return;
            }

            // otherwise, copy selection to target box...
            $lookup.val( $selected.text() );

            // ...and kill submit
            e.preventDefault();

            pokedex_suggestions.hide();
        }
    },

    'scroll_into_view': function($el) {
        var $parent = $el.parent();
        // jQuery apparently relies on reading CSS for position(), which
        // doesn't work so well when I use em.  Use offsetTop directly instead
        var top = $el[0].offsetTop;
        var bottom = top + $el.outerHeight();

        // If the bottom of the element is below the viewport of the parent,
        // scroll down
        var min_scroll = bottom - $parent.innerHeight();
        if ($parent.scrollTop() < min_scroll)
            $parent.scrollTop(min_scroll);

        // If the top of the element is above the viewport of the parent,
        // scroll up.  Do this second so that an element taller than the
        // viewport has its top visible
        var max_scroll = top;
        if ($parent.scrollTop() > max_scroll)
            $parent.scrollTop(max_scroll);
    },

    'move_results': function() {
        var $suggest_box = $('#dex-suggestions');
        if (!$suggest_box.length) return;
        if (!pokedex_suggestions.$lookup_element) return;

        var $lookup = pokedex_suggestions.$lookup_element;
        var position = $lookup.offset();

        $suggest_box.css({
            'top':  (position.top + $lookup.outerHeight()) + 'px',
            'left':  position.left + 'px',
            'width': $lookup.outerWidth() + 'px',
        });
    },

    'hide': function() {
        $('#dex-suggestions').css('visibility', 'hidden');
    },
};

// Set up dex suggestion engine
$(document).ready(function() {
    var $suggest_box = $('<ul id="dex-suggestions"></ul>');
    $suggest_box.css('visibility', 'hidden');
    $('body').append($suggest_box);

    // Attach events to all lookup boxes
    $(".js-dex-suggest")
        .attr("autocomplete", "off")
        .keyup(pokedex_suggestions.change_wrapper)
        .keydown(pokedex_suggestions.keydown)
        .blur(function(){ window.setTimeout(pokedex_suggestions.hide, 100) });

    $(document).resize(pokedex_suggestions.move_results);
    pokedex_suggestions.move_results();
});
