@picked_user_tags = new ReactiveArray []
# @selected_user_roles = new ReactiveArray []


Router.route '/rusers', (->
    @render 'rusers'
    ), name:'rusers'

# Template.term_image.onCreated ->
Template.rusers.onCreated ->
    Session.setDefault('selected_user_location',null)
    Session.setDefault('searching_location',null)
    Session.setDefault('sort_direction',-1)
    
    @autorun -> Meteor.subscribe 'selected_rusers', 
        picked_user_tags.array() 
        Session.get('searching_username')
        Session.get('limit')
        Session.get('sort_key')
        Session.get('sort_direction')
    @autorun -> Meteor.subscribe('user_tags',
        picked_user_tags.array()
        Session.get('username_query')
        # selected_user_roles.array()
        # Session.get('view_mode')
    )

Template.rusers.events
    'click .select_user': ->
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name
    'keyup .search_username': (e,t)->
        val = $('.search_username').val()
        Session.set('searching_username',val)

        if e.which is 13
            Meteor.call 'search_users', val, ->


Template.sort_button.events
    'click .sort': ->
        Session.set('sort_key', @key)
Template.sort_button.helpers
    button_class: ->
        if Session.equals('sort_key', @key) then 'active' else 'basic'
    

# Template.member_card.helpers
#     credit_ratio: ->
#         unless @debit_count is 0
#             @debit_count/@debit_count

# Template.member_card.events
#     'click .calc_points': ->
#         Meteor.call 'calc_user_points', @_id, ->
#     'click .debit': ->
#         # user = Meteor.users.findOne(username:@username)
#         new_debit_id =
#             Docs.insert
#                 model:'debit'
#                 recipient_id: @_id
#         Router.go "/debit/#{new_debit_id}/edit"

#     'click .request': ->
#         # user = Meteor.users.findOne(username:@username)
#         new_id =
#             Docs.insert
#                 model:'request'
#                 recipient_id: @_id
#         Router.go "/request/#{new_id}/edit"

# Template.addtoset_user.helpers
#     ats_class: ->
#         if Template.parentData()["#{@value}"] in @key
#             'blue'
#         else
#             ''

# Template.addtoset_user.events
#     'click .toggle_value': ->
#         Meteor.users.update Template.parentData(1)._id,
#             $addToSet:
#                 "#{@key}": @value



Template.rusers.helpers
    current_username_query: -> Session.get('searching_username')
    users: ->
        match = {model:'user'}
        # unless 'admin' in Meteor.user().roles
        #     match.site = $in:['member']
        if picked_user_tags.array().length > 0 then match.tags = $all: picked_user_tags.array()
        Docs.find match,
            sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))

    all_user_tags: -> results.find(model:'user_tag')
    picked_user_tags: -> picked_user_tags.array()
    # all_site: ->
    #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
    #     if 0 < user_count < 3 then site.find { count: $lt: user_count } else sites.find()
    
    # all_sites: ->
    #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
    #     if 0 < user_count < 3 then User_sites.find { count: $lt: user_count } else User_sites.find()
    # selected_user_sites: ->
    #     # model = 'event'
    #     selected_user_sites.array()
    # all_sites: ->
    #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
    #     if 0 < user_count < 3 then site_results.find { count: $lt: user_count } else site_results.find()
    # selected_user_sites: ->
    #     # model = 'event'
    #     selected_user_sites.array()


        
Template.user_small.events
    'click .add_tag': -> 
        picked_user_tags.push @valueOf()
Template.rusers.events
    'click .pick_user_tag': -> 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        picked_user_tags.push @name
    'click .unpick_user_tag': -> picked_user_tags.remove @valueOf()
    'click #clear_tags': -> picked_user_tags.clear()

    'click .clear_username': (e,t)-> 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance "clear username"
        Session.set('searching_username',null)

    'keyup .search_tags': (e,t)->
        # search = $('.search_site').val().toLowerCase().trim()
        # Session.set('location_query',search)
        if e.which is 13
            search = $('.search_tags').val().trim()
            if search.length > 0
                # window.speechSynthesis.cancel()
                # window.speechSynthesis.speak new SpeechSynthesisUtterance search
                picked_user_tags.push search
                $('.search_tags').val('')

                # Meteor.call 'search_stack', Router.current().params.site, search, ->
                #     Session.set('thinking',false)
    'keyup .search_location': (e,t)->
        # search = $('.search_site').val().toLowerCase().trim()
        search = $('.search_location').val().trim()
        Session.set('location_query',search)
        if e.which is 13
            if search.length > 0
                # window.speechSynthesis.cancel()
                # window.speechSynthesis.speak new SpeechSynthesisUtterance search
                picked_stags.push search
                $('.search_site').val('')

                # Meteor.call 'search_stack', Router.current().params.site, search, ->
                #     Session.set('thinking',false)