Template.registerHelper 'youtube_parse', (url) ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    match = @data.url.match(regExp)
    if match && match[2].length == 11
        match[2]
    else
        null
   
   
   
Template.unpick_tag.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
    
Template.unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.unpick_tag.events
    'click .unpick_tag': -> 
        Session.set('skip',0)
        # console.log @
        picked_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        
   
   
   
   
Session.setDefault('loading', false)
Template.body.events
    'click .set_main': -> Session.set('view_section','main')

    'click .say_body': ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        # Meteor.call 'add_global_karma', ->
        # Session.set('session_clicks', Session.get('session_clicks')+2)

    # 'click a': ->
        # if Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:points:2
        # if @_author_id
        #     Meteor.users.update @_author_id,
        #         $inc:points:2
        # Meteor.call 'add_global_karma', ->
        # Session.set('session_clicks', Session.get('session_clicks')+2)
    
    # 'click body': ->
    #     if Meteor.userId()
    #         Meteor.users.update Meteor.userId(),
    #             $inc:points:1
    #     if @_author_id
    #         Meteor.users.update @_author_id,
    #             $inc:points:1
    #     Meteor.call 'add_global_karma', ->
    #     Session.set('session_clicks', Session.get('session_clicks')+1)
    
    'click .add_global_karma': ->
        Session.set('session_clicks', Session.get('session_clicks')+1)
        Meteor.call 'add_global_karma', ->
    'click .shutup': ->
        window.speechSynthesis.cancel()

    'click .say': ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        
    'click .blink': ->
        $('.global_container')
            .transition('fade out', 150)
            .transition('fade in', 150)
        
        
# Template.say.events
#     'click .quiet': (e,t)->
#         Session.set('talking',false)
#         window.speechSynthesis.cancel()
#     'click .say_this': (e,t)->
#         Session.set('talking',true)
#         dom = document.createElement('textarea')
#         # dom.innerHTML = doc.body
#         dom.innerHTML = Template.parentData()["#{@k}"]
#         text1 = $("<textarea/>").html(dom.innerHTML).text();
#         text2 = $("<textarea/>").html(text1).text();
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance text2

Router.route '/', (->
    @layout 'layout'
    @render 'reddit'
    ), name:'home'




@picked_tags = new ReactiveArray []
Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'home'
    loadingTemplate: 'splash'
    trackPageView: false
# 	progressTick: false
# 	progressDelay: 100
# Router.route '*', -> @render 'not_found'


