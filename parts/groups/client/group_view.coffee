if Meteor.isClient
    Template.group_view.onCreated ->
        @autorun -> Meteor.subscribe 'group_tips', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'group_events', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'group_posts', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'group_badges', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'group_docs', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'me'
        Session.setDefault 'view_group_section', 'images'
    Template.group_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000


    Template.group_badges.helpers
        badges: ->
            Docs.find 
                model:'badge'
                # group_id:@group_id
    Template.group_badges.events
        'click .add_badge': ->
            new_id = 
                Docs.insert
                    model:'badge'
                    group_id:@_id
            Router.go "/badge/#{new_id}/edit"
    
    Template.group_events.helpers
        events: ->
            Docs.find 
                model:'event'
                # group_id:@group_id
    Template.group_events.events
        'click .add_event': ->
            new_id = 
                Docs.insert
                    model:'event'
                    group_id:@_id
            Router.go "/event/#{new_id}/edit"
    
    Template.group_view.events
        'click .add_group_post': ->
            new_id = 
                Docs.insert
                    model:'post'
                    group_id:@_id
            Router.go "/m/post/#{new_id}/edit"
        'click .add_group_gift': ->
            new_id = 
                Docs.insert
                    model:'debit'
                    group_id:@_id
            Router.go "/m/debit/#{new_id}/edit"
        'click .add_group_request': ->
            new_id = 
                Docs.insert
                    model:'request'
                    group_id:@_id
            Router.go "/m/request/#{new_id}/edit"
        'click .tip': ->
            if Meteor.user()
                Meteor.call 'tip', @_id, ->
                    
                Meteor.call 'calc_group_stats', @_id, ->
                Meteor.call 'calc_user_stats', Meteor.userId(), ->
                $('body').toast({
                    class: 'success'
                    position: 'bottom right'
                    message: "#{@title} tipped"
                })
            else 
                Router.go '/login'
    
    Template.group_view.helpers
        tips: ->
            Docs.find
                model:'tip'
        
        group_posts: ->
            Docs.find   
                model:'post'
                group_id:@_id
        
        latest_photos: ->
            Docs.find   
                model:'post'
                group_id:@_id
        
        latest_updates: ->
            Docs.find {
                group_id:@_id
            }, sort: _timestamp:-1
        tippers: ->
            Meteor.users.find
                _id:$in:@tipper_ids
        
        tipper_tips: ->
            # console.log @
            Docs.find
                model:'tip'
                _author_id:@_id
        
        can_claim: ->
            if @claimed_user_id
                false
            else 
                if @_author_id is Meteor.userId()
                    false
                else
                    true

    
    
    Template.group_view.events
        'click .add_tag': ->
            # Meteor.call 'tip', @_id, ->
                
            # Meteor.call 'calc_group_stats', @_id, ->
            # Meteor.call 'calc_user_stats', Meteor.userId(), ->
            # $('body').toast({
            #     class: 'success'
            #     position: 'bottom right'
            #     message: "#{@title} tipped"
            # })
            selected_tags.push @valueOf()
            Meteor.call 'call_wiki', @valueOf(), ->
            Meteor.call 'search_reddit', selected_tags.array(), ->

            Router.go '/'
    

if Meteor.isServer
    Meteor.publish 'group_docs', (group_id)->
        Docs.find
            group_id:group_id
