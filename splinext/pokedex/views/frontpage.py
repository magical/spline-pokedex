import datetime
import logging

from splinext.pokedex.sources import max_age_to_datetime

log = logging.getLogger(__name__)

def index(request):
    """Magicaltastic front page.

    Plugins can register a hook called 'frontpage_updates_<type>' to add
    updates to the front page.  `<type>` is an arbitrary string indicating
    the sort of update the plugin knows how to handle; for example,
    spline-forum has a `frontpage_updates_forum` hook for posting news from
    a specific forum.

    Hook handlers should return a list of FrontPageUpdate objects.

    Standard hook parameters are:
    `limit`, the maximum number of items that should ever be returned.
    `max_age`, the number of seconds after which items expire.
    `title`, a name for the source.
    `icon`, an icon to show next to its name.

    `limit` and `max_age` are also global options.

    Updates are configured in the .ini like so:

        spline-frontpage.sources.foo = updatetype
        spline-frontpage.sources.foo.opt1 = val1
        spline-frontpage.sources.foo.opt2 = val2

    Note that the 'foo' name is completely arbitrary and is only used for
    grouping options together.  This will result in a call to:

        run_hooks('frontpage_updates_updatetype', opt1=val1, opt2=val2)

    Plugins may also respond to the `frontpage_extras` hook with other
    interesting things to put on the front page.  There's no way to
    customize the order of these extras or which appear and which don't, at
    the moment.  Such hooks should return an object with at least a
    `template` attribute; the template will be called with the object
    passed in as its `obj` argument.

    Local plugins can override the fairly simple index.mako template to
    customize the front page layout.
    """
    response = request.response
    config = request.registry.settings
    c = request.tmpl_context

    updates = []
    global_limit = config['spline-frontpage.limit']
    global_max_age = max_age_to_datetime(
        config['spline-frontpage.max_age'])

    c.sources = config['spline-frontpage.sources']
    for source in c.sources:
        new_updates = source.poll(global_limit, global_max_age)
        updates.extend(new_updates)

        # Little optimization: once there are global_limit items, anything
        # older than the oldest cannot possibly make it onto the list.  So,
        # bump global_max_age to that oldest time if this is ever the case.
        updates.sort(key=lambda obj: obj.time, reverse=True)
        del updates[global_limit:]

        if updates and len(updates) == global_limit:
            global_max_age = updates[-1].time

    # Find the oldest unseen item, to draw a divider after it.
    # If this stays as None, the divider goes at the top
    c.last_seen_item = None

    # Could have a timestamp in a cookie
    last_seen_time = None
    try:
        last_seen_time = datetime.datetime.fromtimestamp(
            int(request.cookies['frontpage-last-seen-time']))
    except (KeyError, ValueError):
        pass

    if last_seen_time:
        for update in updates:
            if update.time > last_seen_time:
                c.last_seen_item = update
            else:
                break

    # Save ~now~ as the last-seen time
    now = datetime.datetime.now().strftime('%s')
    response.set_cookie('frontpage-last-seen-time', now)

    # Done!  Feed to template
    c.updates = updates

    # Hook for non-update interesting things to put on the front page.
    # This hook should return objects with a 'template' attribute, and
    # whatever else they need
    c.extras = []

    return {}
