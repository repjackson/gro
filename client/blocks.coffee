if Meteor.isClient
    Template.print_this.events
        'click .print_this': ->
            console.log @
    Template.smart_tagger.onCreated ->
        # @autorun => @subscribe 'tag_results',
        #     # Router.current().params.doc_id
        #     selected_tags.array()
        #     Session.get('searching')
        #     Session.get('current_query')
        #     Session.get('dummy')

    Template.smart_tagger.helpers        
        # terms: -> Terms.find()
        # suggestions: -> Tag_results.find()

    Template.smart_tagger.events
        'keyup .new_tag': _.throttle((e,t)->
            query = $('.new_tag').val()
            if query.length > 0
                Session.set('searching', true)
            else
                Session.set('searching', false)
            Session.set('current_query', query)
            
            if e.which is 13
                element_val = t.$('.new_tag').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                selected_tags.push element_val
                # Meteor.call 'log_term', element_val, ->
                Session.set('searching', false)
                Session.set('current_query', '')
                Meteor.call 'add_tag', @_id, ->
    
                # Session.set('dummy', !Session.get('dummy'))
                t.$('.new_tag').val('')
        , 250)

        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            selected_tags.remove element
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)
            # Session.set('dummy', !Session.get('dummy'))
    
    
        'click .select_term': (e,t)->
            # selected_tags.push @title
            Docs.update Router.current().params.doc_id,
                $addToSet:tags:@title
            selected_tags.push @title
            $('.new_tag').val('')
            Session.set('current_query', '')
            Session.set('searching', false)
            # Session.set('dummy', !Session.get('dummy'))


    Template.vote.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'author_vote', @data._id

    Template.vote.helpers
        user_vote: ->
            Docs.findOne 
                model:'vote'
                parent_id:@_id
                _author_id:Meteor.userId()
            
    Template.vote.events
        'click .upvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            # if Meteor.user()
            Meteor.call 'upvote', @_id, ->
            #     Meteor.call 'calc_post_votes', @_id, ->
            # else
            #     Router.go "/register"
        'click .downvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            # if Meteor.user()
            Meteor.call 'downvote', @_id, ->
            # Meteor.call 'calc_post_votes', @_id, ->
            # else
            #     Router.go "/register"




    Template.session_toggle_button.helpers
        session_toggle_button_class: ->
            if Template.instance().subscriptionsReady()
                if Session.get(@key) then 'grey' else 'basic'
            else
                'disabled loading'
    Template.session_toggle_button.events
        'click .toggle': -> Session.set(@key, !Session.get(@key))
#
    Template.comments.onRendered ->
        # Meteor.setTimeout ->
        #     $('.menu .item').tab()
        # , 2000
    Template.comments.onCreated ->
        # if Router.current().params.doc_id
        #     parent = Docs.findOne Router.current().params.doc_id
        # else
        #     parent = Docs.findOne Template.parentData()._id
        # if parent
        @autorun => Meteor.subscribe 'children', 'comment', Router.current().params.doc_id
    Template.comments.helpers
        doc_comments: ->
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else
                parent = Docs.findOne Template.parentData()._id
            if Meteor.user()
                Docs.find
                    parent_id:parent._id
                    model:'comment'
            else
                Docs.find
                    model:'comment'
                    parent_id:parent._id
                    _author_id:$exists:false
                    
    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                if Router.current().params.doc_id
                    parent = Docs.findOne Router.current().params.doc_id
                else
                    parent = Docs.findOne Template.parentData()._id
                # parent = Docs.findOne Router.current().params.doc_id
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: parent._id
                    model:'comment'
                    parent_model:parent.model
                    body:comment
        
                t.$('.add_comment').val('')
                Meteor.call 'calc_user_stats', Meteor.userId(), ->

        'click .remove_comment': ->
            if confirm 'Confirm remove comment'
                Docs.remove @_id

    Template.follow.helpers
        followers: ->
            Meteor.users.find
                _id: $in: @follower_ids
        following: -> @follower_ids and Meteor.userId() in @follower_ids
    Template.follow.events
        'click .follow': ->
            Docs.update @_id,
                $addToSet:follower_ids:Meteor.userId()
        'click .unfollow': ->
            Docs.update @_id,
                $pull:follower_ids:Meteor.userId()
#
#
#
#     Template.session_key_value.events
#         'click .set_session_value': ->
#             console.log @
#             if Session.equals(@key,@value)
#                 Session.set(@key, null)
#             else
#                 Session.set(@key, @value)
#
#     Template.session_key_value.helpers
#         button_class: ->
#             console.log @
#             if Session.equals(@key, @value) then 'active' else 'basic'
#
#
#
#
#
    Template.voting.events
        'click .upvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            if Meteor.user()
                Meteor.call 'upvote', @, ->
            else
                Router.go "/register"
        'click .downvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            if Meteor.user()
                Meteor.call 'downvote', @, ->
            else
                Router.go "/register"
    Template.voting_small.events
        'click .upvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @, ->
#
#
#

if Meteor.isServer
    Meteor.methods 
        calc_post_votes: (doc_id)->
            doc = Docs.findOne doc_id
            # console.log 'post', doc
            votes = 
                Docs.find 
                    model:'vote'
                    parent_id:doc_id
            total_doc_points = 0
            for vote in votes.fetch()
                total_doc_points += vote.points
                
            Docs.update doc_id, 
                $set:
                    points:total_doc_points
                    
                    
    Meteor.publish 'author_vote', (parent_id)->
        Docs.find 
            model:'vote'
            parent_id:parent_id


if Meteor.isClient
#     Template.doc_card.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Template.currentData().doc_id
#     Template.doc_card.helpers
#         doc: ->
#             Docs.findOne
#                 _id:Template.currentData().doc_id
#
#
#
#
#
#     # Template.call_watson.events
#     #     'click .autotag': ->
#     #         doc = Docs.findOne Router.current().params.doc_id
#     #         console.log doc
#     #         console.log @
#     #
#     #         Meteor.call 'call_watson', doc._id, @key, @mode
#
    Template.voting_full.events
        'click .upvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @, ->


#
#
#     Template.role_editor.onCreated ->
#         @autorun => Meteor.subscribe 'model', 'role'
#
#
#
#
#     Template.small_horizontal_user_card.onCreated ->
#         @autorun => Meteor.subscribe 'user_from_username', @data
#     Template.small_horizontal_user_card.helpers
#         user: -> Meteor.users.findOne username:@valueOf()
#
#
#
#     Template.big_user_card.onCreated ->
#         @autorun => Meteor.subscribe 'user_from_username', @data
#     Template.big_user_card.helpers
#         user: -> Meteor.users.findOne username:@valueOf()
#
#
#
#
#     Template.username_info.onCreated ->
#         @autorun => Meteor.subscribe 'user_from_username', @data
#     Template.username_info.events
#         'click .goto_profile': ->
#             user = Meteor.users.findOne username:@valueOf()
#             Router.go "/u/#{user.username}/"
#     Template.username_info.helpers
#         user: -> Meteor.users.findOne username:@valueOf()
#
#
#

    Template.user_info.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_info.helpers
        user: -> Meteor.users.findOne @valueOf()
    
    Template.user_info_small.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_info_small.helpers
        user: -> Meteor.users.findOne @valueOf()
    
    Template.user_info_tiny.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_info_tiny.helpers
        user: -> Meteor.users.findOne @valueOf()

#
    Template.user_avatar.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_avatar.helpers
        user: -> Meteor.users.findOne @valueOf()

#
#     Template.toggle_edit.events
#         'click .toggle_edit': ->
#             console.log @
#             console.log Template.currentData()
#             console.log Template.parentData()
#             console.log Template.parentData(1)
#             console.log Template.parentData(2)
#             console.log Template.parentData(3)
#             console.log Template.parentData(4)
#
#
#
#
#
#     Template.user_list_info.onCreated ->
#         @autorun => Meteor.subscribe 'user', @data
#
#     Template.user_list_info.helpers
#         user: ->
#             console.log @
#             Meteor.users.findOne @valueOf()
#
#
#
    Template.bookmark_button.events
        'click .toggle': (e,t)->
            console.log @
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            if Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids
                Meteor.users.update Meteor.userId(),
                    $pull:"bookmark_ids": @_id
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet:"bookmark_ids": @_id

    Template.bookmark_button.helpers
        bookmark_button_class: ->
            if Meteor.user()
                if Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids then 'active' else 'basic'
            else
                'disabled'

        bookmarked: ->
            if Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids then true else false
#
#
#
#
    Template.user_list_toggle.onCreated ->
        @autorun => Meteor.subscribe 'user_list', Template.parentData(),@key
    Template.user_list_toggle.events
        'click .toggle': (e,t)->
            parent = Template.parentData()
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"]
                Docs.update parent._id,
                    $pull:"#{@key}":Meteor.userId()
            else
                Docs.update parent._id,
                    $addToSet:"#{@key}":Meteor.userId()
    Template.user_list_toggle.helpers
        user_list_toggle_class: ->
            if Meteor.user()
                parent = Template.parentData()
                if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then 'active' else 'basic'
            else
                'disabled'
        in_list: ->
            parent = Template.parentData()
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then true else false
        list_users: ->
            parent = Template.parentData()
            Meteor.users.find(_id:$in:parent["#{@key}"]).fetch()

#
#
#
    Template.viewing.events
        'click .mark_read': (e,t)->
            Docs.update @_id,
                $inc:views:1
            unless @read_ids and Meteor.userId() in @read_ids
                Meteor.call 'mark_read', @_id, ->
                    # $(e.currentTarget).closest('.comment').transition('pulse')
                    $('.unread_icon').transition('pulse')
        'click .mark_unread': (e,t)->
            Docs.update @_id,
                $inc:views:-1
            Meteor.call 'mark_unread', @_id, ->
                # $(e.currentTarget).closest('.comment').transition('pulse')
                $('.unread_icon').transition('pulse')
    Template.viewing.helpers
        viewed_by: -> Meteor.userId() in @read_ids
        readers: ->
            readers = []
            if @read_ids
                for reader_id in @read_ids
                    unless reader_id is @_author_id
                        readers.push Meteor.users.findOne reader_id
            readers
#
#
#
#
if Meteor.isClient
    Template.email_validation_check.events
        'click .send_verification': ->
            console.log @
            if confirm 'send verification email?'
                Meteor.call 'verify_email', @_id, ->
                    alert 'verification email sent'
        'click .toggle_email_verified': ->
            console.log @emails[0].verified
            if @emails[0]
                Meteor.users.update @_id,
                    $set:"emails.0.verified":true
#
#
#     Template.add_button.onCreated ->
#         # console.log @
#         Meteor.subscribe 'model_from_slug', @data.model
#     Template.add_button.helpers
#         model: ->
#             data = Template.currentData()
#             Docs.findOne
#                 model: 'model'
#                 slug: data.model
#     Template.add_button.events
#         'click .add': ->
#             new_id = Docs.insert
#                 model: @model
#             Router.go "/m/#{@model}/#{new_id}/edit"
#
#
    Template.remove_button.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                # if $(e.currentTarget).closest('.card')
                #     $(e.currentTarget).closest('.card').transition('fly right', 1000)
                # else
                #     $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                #     $(e.currentTarget).closest('.item').transition('fly right', 1000)
                #     $(e.currentTarget).closest('.content').transition('fly right', 1000)
                #     $(e.currentTarget).closest('tr').transition('fly right', 1000)
                #     $(e.currentTarget).closest('.event').transition('fly right', 1000)
                # Meteor.setTimeout =>
                Docs.remove @_id
                # , 1000


    Template.remove_icon.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000

#
#     Template.view_user_button.events
#         'click .view_user': ->
#             Router.go "/u/#{username}"
#
#
#     Template.user_array_element_toggle.helpers
#         user_array_element_toggle_class: ->
#             # user = Meteor.users.findOne Router.current().params.username
#             if @user["#{@key}"] and @value in @user["#{@key}"] then 'active' else 'basic'
#     Template.user_array_element_toggle.events
#         'click .toggle_element': (e,t)->
#             # user = Meteor.users.findOne Router.current().params.username
#             if @user["#{@key}"]
#                 if @value in @user["#{@key}"]
#                     Meteor.users.update @user._id,
#                         $pull: "#{@key}":@value
#                 else
#                     Meteor.users.update @user._id,
#                         $addToSet: "#{@key}":@value
#             else
#                 Meteor.users.update @user._id,
#                     $addToSet: "#{@key}":@value
#
#
#     Template.user_array_list.helpers
#         users: ->
#             users = []
#             if @user["#{@array}"]
#                 for user_id in @user["#{@array}"]
#                     user = Meteor.users.findOne user_id
#                     users.push user
#                 users
#
#
#
#     Template.user_array_list.onCreated ->
#         @autorun => Meteor.subscribe 'user_array_list', @data.user, @data.array
#     Template.user_array_list.helpers
#         users: ->
#             users = []
#             if @user["#{@array}"]
#                 for user_id in @user["#{@array}"]
#                     user = Meteor.users.findOne user_id
#                     users.push user
#                 users
#
#
#
#
    Template.key_value_edit.events
        'click .set_key_value': ->
            parent = Template.parentData()
            # console.log 'hi'
            # parent = Docs.findOne Router.current().params.doc_id
            Docs.update parent._id,
                $set: "#{@key}": @value

    Template.key_value_edit.helpers
        set_key_value_class: ->
            # parent = Docs.findOne Router.current().params.doc_id
            parent = Template.parentData()
            # console.log parent
            if parent["#{@key}"] is @value then 'active' else 'basic'
    
    Template.user_key_value_edit.events
        'click .set_key_value': ->
            parent = Template.parentData()
            # console.log 'hi'
            # parent = Docs.findOne Router.current().params.doc_id
            Meteor.users.update parent._id,
                $set: "#{@key}": @value

    Template.user_key_value_edit.helpers
        set_key_value_class: ->
            # parent = Docs.findOne Router.current().params.doc_id
            parent = Template.parentData()
            # console.log parent
            if parent["#{@key}"] is @value then 'active' else 'basic'

    Template.session_edit_value_button.events
        'click .set_session_value': ->
            # console.log @key
            # console.log @value
            if Session.equals(@key,@value)
                Session.set(@key, null)
            else
                Session.set(@key, @value)

    Template.session_edit_value_button.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @classes
                res += @classes
            if Session.get(@key)
                if Session.equals(@key,@value)
                    res += ' active large compact'
                else
                    res += ' compact displaynone'
                # console.log res
                res



    Template.session_boolean_toggle.events
        'click .toggle_session_key': ->
            console.log @key
            Session.set(@key, !Session.get(@key))

    Template.session_boolean_toggle.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @classes
                res += @classes
            if Session.get(@key)
                res += ' black'
            else
                res += ' basic'

            # console.log res
            res

#
#
#     Template.doc_array_togggle.helpers
#         doc_array_toggle_class: ->
#             parent = Template.parentData()
#             # user = Meteor.users.findOne Router.current().params.username
#             if parent["#{@key}"] and @value in parent["#{@key}"] then 'active' else 'basic'
#     Template.doc_array_togggle.events
#         'click .toggle': (e,t)->
#             parent = Template.parentData()
#             if parent["#{@key}"]
#                 if @value in parent["#{@key}"]
#                     Docs.update parent._id,
#                         $pull: "#{@key}":@value
#                 else
#                     Docs.update parent._id,
#                         $addToSet: "#{@key}":@value
#             else
#                 Docs.update parent._id,
#                     $addToSet: "#{@key}":@value
#
#
#
#
#
#
#
#
#
# if Meteor.isServer
#     Meteor.methods
#         'send_kiosk_message': (message)->
#             parent = Docs.findOne message.parent._id
#             Docs.update message._id,
#                 $set:
#                     sent: true
#                     sent_timestamp: Date.now()
#             Docs.insert
#                 model:'log_event'
#                 log_type:'kiosk_message_sent'
#                 text:"kiosk message sent"
#
#
#     Meteor.publish 'rules_signed_username', (username)->
#         Docs.find
#             model:'rules_and_regs_signing'
#             student:username
#             # agree:true
#
#     Meteor.publish 'type', (type)->
#         Docs.find
#             type:type
#
#     Meteor.publish 'user_guidelines_username', (username)->
#         Docs.find
#             model:'user_guidelines_signing'
#             # student:username
#             # agree:true
#
#     Meteor.publish 'guests', ()->
#         Meteor.users.find
#             roles:$in:['guest']
#
#
#     Meteor.publish 'children', (model, parent_id, limit)->
#         # console.log model
#         # console.log parent_id
#         limit = if limit then limit else 10
#         Docs.find {
#             model:model
#             parent_id:parent_id
#         }, limit:limit