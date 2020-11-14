if Meteor.isClient
    @selected_stack_tags = new ReactiveArray []
    @selected_site_tags = new ReactiveArray []

    Router.route '/subreddits', (->
        @layout 'layout'
        @render 'subreddits'
        ), name:'subreddits'

    

  
    Template.subreddits.events
        'click .goto_site': -> 
            selected_tags.clear()
        # 'click .site': -> 
        #     console.log @valueOf()
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance @name

  
  

            
                
    Template.subreddits.onCreated ->
        # @autorun => Meteor.subscribe 'stack_docs',
        #     selected_stack_tags.array()
        @autorun -> Meteor.subscribe 'subreddits',
            selected_tags.array()
            Session.get('site_name_filter')
    Template.subreddits.helpers
        sub_docs: ->
            Docs.find
                model:'subreddit'
        # stack_docs: ->
        #     Docs.find
        #         model:'stack_question'

    Template.subreddits.events
        # 'click .doc': ->
        #     console.log @
        # 'click .dl': ->
        #     Meteor.call 'subreddits'
        # 'keyup .search_site_name': ->
        #     search = $('.search_site_name').val()
        #     Session.set('site_name_filter', search)
            
   
   


if Meteor.isServer
    Meteor.publish 'subreddits', (selected_tags=[], title='')->
        match = {model:$in:'subreddit'}
        match.site_type = 'main_site'
        if selected_tags.length > 0
            match.tags = $all: selected_tags
        if title.length > 0
            match.title = {$regex:"#{title}", $options:'i'}
        Docs.find match,
            limit:300
    
    Meteor.publish 'question_answers', (question_doc_id)->
        question = Docs.findOne question_doc_id
        console.log question.question_id
        Docs.find 
            model:'stack_answer'
            site:question.site
            question_id:question.question_id
    
    Meteor.publish 'stackuser_doc', (site,user_id)->
        console.log 'looking for', site, user_id
        Docs.find 
            model:'stackuser'
            user_id:parseInt(user_id)
            site:site
    
    Meteor.publish 'site_by_param', (site)->
        Docs.find 
            model:'stack_site'
            api_site_parameter:site
    
    # Meteor.publish 'stack_docs', ->
    #     Docs.find {
    #         model:'stack'
    #     },
    #         limit:20
            
            