if Meteor.isClient
    Router.route '/u/:username/credits', (->
        @layout 'profile_layout'
        @render 'user_credits'
        ), name:'user_credits'


    Template.user_credits.onCreated ->
        @autorun => Meteor.subscribe 'user_credits', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'debit'

    Template.user_credits.events
        # 'keyup .new_credit': (e,t)->
        #     if e.which is 13
        #         val = $('.new_credit').val()
        #         console.log val
        #         target_user = Meteor.users.findOne(username:Router.current().params.username)
        #         Docs.insert
        #             model:'credit'
        #             body: val
        #             target_id: target_user._id



    Template.user_credits_small.helpers
        user_credits: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                target_id: target_user._id
            },
                sort:_timestamp:-1

    Template.user_credits.helpers
        user_credits: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                target_id: target_user._id
            },
                sort:_timestamp:-1




if Meteor.isServer
    Meteor.publish 'user_credits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'debit'
            target_id:user._id
