Router.route '/p/:doc_id', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view_short'


Template.post_view.onCreated ->
    Session.set('post_view_mode', 'main')
    Meteor.call 'log_view', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    

Template.post_view.helpers
    

Template.post_view.events
    'click .set_main': ->
        Session.set('post_view_mode', 'main')
    'click .set_emotion': ->
        Session.set('post_view_mode', 'emotion')
    'click .set_tone': ->
        Session.set('post_view_mode', 'tone')
    'click .set_cleaned': ->
        Session.set('post_view_mode', 'cleaned')
    
    'click .set_comments': ->
        Session.set('post_view_mode', 'comments')
    'click .search_sub': ->
        # picked_tags.clear()
        unless @subreddit.toLowerCase() in picked_tags.array()
            picked_tags.push @subreddit.toLowerCase()
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout ->
            Session.set('toggle', !Session.get('toggle'))
        , 7000    
        
        Router.go '/'

