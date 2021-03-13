if Meteor.isClient
    Router.route '/u/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard_long'
    Router.route '/u/:username/comments', (->
        @layout 'profile_layout'
        @render 'user_comments'
        ), name:'user_comments'
    Router.route '/u/:username/posts', (->
        @layout 'profile_layout'
        @render 'user_posts'
        ), name:'user_posts'
    Router.route '/u/:username/upvoted', (->
        @layout 'profile_layout'
        @render 'user_upvoted'
        ), name:'user_upvoted'
    Router.route '/u/:username/downvoted', (->
        @layout 'profile_layout'
        @render 'user_downvoted'
        ), name:'user_downvoted'
    Router.route '/u/:username/vault', (->
        @layout 'profile_layout'
        @render 'user_vault'
        ), name:'user_vault'
    Router.route '/u/:username/tips', (->
        @layout 'profile_layout'
        @render 'user_tips'
        ), name:'user_tips'
    Router.route '/u/:username/bounties', (->
        @layout 'profile_layout'
        @render 'user_bounties'
        ), name:'user_bounties'
    Router.route '/u/:username/groups', (->
        @layout 'profile_layout'
        @render 'user_groups'
        ), name:'user_groups'

    Template.user_vault.onCreated ->
        @autorun -> Meteor.subscribe 'user_vault', Router.current().params.username
    Template.user_vault.helpers
        private_posts: -> 
            user = Meteor.users.findOne(username:Router.current().params.username)

            Docs.find 
                model:'post'
                is_private:true
                _author_id:user._id
   
   
   
   
    Template.user_comments.onCreated ->
        @autorun -> Meteor.subscribe 'user_comments', Router.current().params.username
    Template.user_comments.helpers
        comments: -> Docs.find model:'comment'
   
    Template.user_tips.onCreated ->
        @autorun -> Meteor.subscribe 'user_tips', Router.current().params.username
    Template.user_tips.helpers
        tips: -> Docs.find model:'tip'

    Template.user_posts.onCreated ->
        @autorun -> Meteor.subscribe 'user_posts', Router.current().params.username
    Template.user_posts.helpers
        posts: -> Docs.find model:'post'


    # Template.user_bounties.onCreated ->
    #     @autorun -> Meteor.subscribe 'user_bounties', Router.current().params.username
    # Template.user_bounties.helpers
    #     bountys: -> Docs.find model:'bounty'


    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_post_count', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_comment_count', Router.current().params.username
  
    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'user_tips_received_count', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_tips_sent_count', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_karma_sent', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_karma_received', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_feed_items', Router.current().params.username
        @autorun -> Meteor.subscribe 'model_docs', 'bounty'
    Template.user_dashboard.events
        'click .mark_viewed': ->
            console.log @
            $('body').toast({
                message: 'marked read'
                class: 'success'
            })
            
            Meteor.call 'mark_viewed', @_id, ->
    
        'click .user_credit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
        'click .user_debit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
        'click .user_checkin_segment': ->
            Router.go "/drink/#{@drink_id}/view"
            
        'keyup .add_feed_item': (e,t)->
            if e.which is 13
                val = $('.add_feed_item').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'feed_item'
                    body: val
                    target_user_id: target_user._id
                    target_user_username: target_user.username
                val = $('.add_feed_item').val('')

            
    Template.user_dashboard.helpers
        bounties_from: -> 
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            
            Docs.find {
                model:'bounty'
                _author_id:target_user._id
            },
                sort:
                    _timestamp:-1
        bounties_to: -> 
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            
            Docs.find {
                model:'bounty'
                target_id:target_user._id
            },
                sort:
                    _timestamp:-1
        feed_items: -> 
            Docs.find {
                model:'feed_item'
            },
                sort:
                    _timestamp:-1
        user_post_count: -> Counts.get 'user_post_count'
        post_points: -> Counts.get('user_post_count')*10
        user_comment_count: -> Counts.get 'user_comment_count'
        user_tips_sent_count: -> Counts.get 'user_tips_sent_count'
        user_tips_received_count: -> Counts.get 'user_tips_received_count'

        user_karma_received: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find 
                model:'debit'
                target_id:current_user._id
        user_karma_sent: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find 
                model:'debit'
                _author_id:current_user._id
        user_referred: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Meteor.users.find 
                referrer:current_user._id
        user_comments: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'comment'
                _author_id: current_user._id
            }, 
                limit: 10
                sort: _timestamp:-1
        user_debits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                _author_id: current_user._id
            }, 
                limit: 10
                sort: _timestamp:-1
        user_credits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'bounty'
                target_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10
      
        user_credits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                target_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10
      
        user_groups: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'group'
                member_ids: $in:[current_user._id]
            }, 
                sort: _timestamp:-1
                limit: 10


        group_bookmarks: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'group_bookmark'
                _author_id:user._id
            }, sort:search_amount:-1
        posts: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'post'
                _author_id:user._id
            }, 
                sort:
                    search_amount:-1
                limit:10
        tips: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'tip'
                _author_id:user._id
            }, sort:amount:-1
                
        reflections: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'reflections'
                _author_id:user._id
            }, sort:_timestamp:-1
        comments: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'comment'
                _author_id:user._id
            }, sort:_timestamp:-1
                
        
        
    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
    
    Template.profile_layout.onRendered ->
        # Meteor.setTimeout ->
        #     $('.no_blink')
        #         .popup()
        # , 1000
        user = Meteor.users.findOne(username:Router.current().params.username)
        Meteor.setTimeout ->
            if user
                Meteor.call 'calc_user_stats', user._id, ->
                Meteor.call 'log_user_view', user._id, ->
        , 2000


    Template.profile_layout.helpers
        route_slug: -> "user_#{@slug}"
        user: -> Meteor.users.findOne username:Router.current().params.username
        user_comment_count: -> Counts.get 'user_comment_count'
        user_post_count: -> Counts.get 'user_post_count'

    Template.profile_layout.events
    
        'click a.select_term': ->
            $('.profile_yield')
                .transition('fade out', 200)
                .transition('fade in', 200)
        'click .click_group': (e,t)->
            # $('.label')
            #     .transition('fade out', 200)
            Router.go "/g/#{@name}"
        'keyup .goto_group': (e,t)->
            if e.which is 13
                val = $('.goto_group').val()
                found_group =
                    Docs.findOne 
                        model:'group_bookmark'
                        name:val
                if found_group
                    Docs.update found_group._id,
                        $inc:search_amount:1
                else
                    Docs.insert 
                        model:'group_bookmark'
                        search_amount:1
                        name:val
                # $('.header')
                #     .transition('scale', 200)
                # $('.global_container')
                #     .transition('scale', 400)
                Router.go "/g/#{val}"
                # target_user = Meteor.users.findOne(username:Router.current().params.username)
                # Docs.insert
                #     model:'debit'
                #     body: val
                #     target_user_id: target_user._id
        'click .remove_group': ->
            if confirm 'remove group?'
                Docs.remove @_id
        # 'click .goto_users': ->
        #     $('.global_container')
        #         .transition('fade right', 500)
        #         # .transition('fade in', 200)
        #     Meteor.setTimeout ->
        #         Router.go '/users'
        #     , 500
    
    
        'click .refresh_user_stats': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            # Meteor.call 'calc_user_stats', user._id, ->
            Meteor.call 'calc_user_stats', user._id, ->
            Meteor.call 'calc_user_tags', user._id, ->
    
        'click .send': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            if Meteor.userId() is user._id
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        amount:1
            else
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        amount:1
                        target_id: user._id
            Router.go "/debit/#{new_debit_id}/edit"


        'click .tip': ->
            # user = Meteor.users.findOne(username:@username)
            new_debit_id =
                Docs.insert
                    model:'debit'
            Router.go "/debit/#{new_debit_id}/edit"


        # 'click .recalc_user_cloud': ->
        #     Meteor.call 'recalc_user_cloud', Router.current().params.username, ->

        'click .logout': ->
            # Router.go '/login'
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false





if Meteor.isServer
    Meteor.publish 'user_karma_received', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'debit'
            target_id:user._id
        }
        Docs.find match,
            limit:20
            sort:
                _timestamp:-1
    
    Meteor.publish 'user_bounties', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'bounty'
            _author_id:user._id
        }
        Docs.find match,
            limit:20
            sort:
                _timestamp:-1
    
    
    Meteor.publish 'user_karma_sent', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'debit'
            _author_id:user._id
        }
        Docs.find match,
            limit:20
            sort:
                _timestamp:-1
    
    Meteor.publish 'user_tips', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'tip'
            _author_id:user._id
        }
        Docs.find match,
            limit:20
            sort:
                _timestamp:-1
    
    Meteor.publish 'user_vault', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'post'
            is_private:true
            _author_id:user._id
        }
        Docs.find match,
            limit:20
            sort:
                _timestamp:-1
    
    
    Meteor.publish 'user_feed_items', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'feed_item'
            target_user_id:user._id
        }
        Docs.find match,
            sort:_timestamp:-1
    
    Meteor.publish 'user_post_count', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'post'
            _author_id:user._id
        }
    
        # match.tags = $all:picked_tags
        # if picked_tags.length
        Counts.publish this, 'user_post_count', Docs.find(match)
        return undefined
    
    Meteor.publish 'user_comment_count', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'comment'
            _author_id:user._id
        }
    
        # match.tags = $all:picked_tags
        # if picked_tags.length
        Counts.publish this, 'user_comment_count', Docs.find(match)
        return undefined
    
    Meteor.publish 'user_tip_count', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'tip'
            _author_id:user._id
        }
    
        # match.tags = $all:picked_tags
        # if picked_tags.length
        Counts.publish this, 'user_tip_count', Docs.find(match)
        return undefined
    
    Meteor.methods
        log_user_view: (user_id)->
            if Meteor.user()
                unless user_id is Meteor.userId()
                    Meteor.users.update user_id,
                        $inc:profile_views:1
            
        # calc_test_sessions: (user_id)->
        #     user = Meteor.users.findOne user_id
        #     now = Date.now()
        #     console.log now
        #     past_24_hours = now-(24*60*60*1000)
        #     past_week = now-(7*24*60*60*1000)
        #     past_month = now-(30*7*24*60*60*1000)
        #     console.log past_24_hours
        #     all_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             }).count()
        #     todays_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             _timestamp:
        #                 $gt:past_24_hours
        #             }).count()
        #     weeks_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             _timestamp:
        #                 $gt:past_week
        #             }).count()
        #     months_sessions_count =
        #         Docs.find({
        #             model:'test_session'
        #             _author_id:username
        #             _timestamp:
        #                 $gt:past_month
        #             }).count()
        #     console.log 'all session count', all_sessions_count
        #     console.log 'today sessions count', todays_sessions_count
        #     Meteor.users.update user_id,
        #         $set:
        #             all_sessions_count:all_sessions_count
        #             todays_sessions_count: todays_sessions_count
        #             weeks_sessions_count: weeks_sessions_count
        #             months_sessions_count: months_sessions_count

        #     # this_week = moment().startOf('isoWeek')
        #     # this_week = moment().startOf('isoWeek')


        # recalc_user_act_stats: (user_id)->
        #     user = Meteor.users.findOne user_id
        #     test_session_cursor =
        #         Docs.find
        #             model:'test_session'
        #             _author_id: user_id
        #     site_test_cursor =
        #         Docs.find(
        #             model:'test'
        #         )
        #     site_test_count = site_test_cursor.count()
        #     answered_tests = 0
        #     for test in site_test_cursor.fetch()
        #         user_test_session =
        #             Docs.findOne
        #                 model:'test_session'
        #                 test_id: test._id
        #                 _author_id:username
        #         if user_test_session
        #             answered_tests++
        #     console.log 'answered tests', answered_tests
        #     global_section_percent = 0

        #     session_count = test_session_cursor.count()
        #     for section in ['english', 'math', 'science', 'reading']
        #         section_test_cursor =
        #             Docs.find {
        #                 model:'test'
        #                 tags: $in: [section]
        #             }
        #         section_count = section_test_cursor.count()
        #         section_tests = section_test_cursor.fetch()
        #         section_test_ids = []
        #         for section_test in section_tests
        #             section_test_ids.push section_test._id

        #         # console.log section
        #         # console.log section_test_ids
        #         user_section_test_sessions =
        #             Docs.find {
        #                 model:'test_session'
        #                 test_id: $in: section_test_ids
        #                 _author_id: user_id
        #             }
        #         # console.log user_section_test_sessions.fetch()
        #         user_section_test_session_count = user_section_test_sessions.count()
        #         total_section_average = 0
        #         for test_session in user_section_test_sessions.fetch()
        #             if test_session.correct_percent
        #                 total_section_average += parseInt(test_session.correct_percent)
        #         user_section_average = total_section_average/user_section_test_session_count
        #         # console.log 'user section average', section, user_section_average
        #         if user_section_average
        #             Meteor.users.update user_id,
        #                 $set:
        #                     "#{section}_average": user_section_average.toFixed()
        #             global_section_percent += user_section_average
        #         else
        #             Meteor.users.update user_id,
        #                 $set:
        #                     "#{section}_average": 0
        #     site_percent_complete = parseInt((answered_tests/site_test_count)*100)
        #     global_section_average = global_section_percent/4



        #     Meteor.users.update user_id,
        #         $set:
        #             session_count:session_count
        #             site_percent_complete:site_percent_complete
        #             global_section_average:global_section_average.toFixed()


        #     section_average_ranking =
        #         Meteor.users.find(
        #             {},
        #             sort:
        #                 global_section_average: -1
        #             fields:
        #                 username: 1
        #         ).fetch()
        #     section_average_ranking_ids = _.pluck section_average_ranking, '_id'

        #     console.log 'section average ranking', section_average_ranking
        #     console.log 'section average ranking ids', section_average_ranking_ids
        #     my_rank = _.indexOf(section_average_ranking_ids, user_id)+1
        #     console.log 'my rank', my_rank
        #     Meteor.users.update user_id,
        #         $set:
        #             global_section_average_rank:my_rank


        #     # average_english_percent
        #     # average_math_percent
        #     # average_science_percent
        #     # average_reading_percent


        # recalc_user_cloud: (user_id)->
        #     user = Meteor.users.findOne user_id
        #     test_session_cursor =
        #         Docs.find
        #             model:'test_session'
        #             _author_id: user_id
        #             right_tags: $exists: true
        #     all_right_tags = []
        #     all_wrong_tags = []
        #     right_tag_list = []
        #     wrong_tag_list = []
        #     right_tag_cloud = []
        #     wrong_tag_cloud = []

        #     for test_session in test_session_cursor.fetch()
        #         for right_tag in test_session.right_tags
        #             unless right_tag in right_tag_list
        #                 right_tag_list.push right_tag
        #             all_right_tags.push right_tag
        #             tag_object = _.findWhere(right_tag_cloud, {tag: right_tag})
        #             # console.log tag_object
        #             if tag_object
        #                 index_of_tag = _.indexOf(right_tag_cloud, tag_object)
        #                 # console.log 'index of tag', index_of_tag
        #                 tag_count = tag_object.count
        #                 # console.log tag_count
        #                 # console.log 'inc', tag_count++
        #                 right_tag_cloud[index_of_tag] = {
        #                     tag:right_tag
        #                     count:tag_count+1
        #                 }
        #             else
        #                 tag_object = {
        #                     tag:right_tag
        #                     count: 1
        #                 }
        #                 right_tag_cloud.push tag_object
        #         for wrong_tag in test_session.wrong_tags
        #             unless wrong_tag in wrong_tag_list
        #                 wrong_tag_list.push wrong_tag
        #             all_wrong_tags.push wrong_tag
        #             tag_object = _.findWhere(wrong_tag_cloud, {tag: wrong_tag})
        #             # console.log tag_object
        #             if tag_object
        #                 index_of_tag = _.indexOf(wrong_tag_cloud, tag_object)
        #                 # console.log 'index of tag', index_of_tag
        #                 tag_count = tag_object.count
        #                 # console.log tag_count
        #                 # console.log 'inc', tag_count++
        #                 wrong_tag_cloud[index_of_tag] = {
        #                     tag:wrong_tag
        #                     count:tag_count+1
        #                 }
        #             else
        #                 tag_object = {
        #                     tag:wrong_tag
        #                     count: 1
        #                 }
        #                 wrong_tag_cloud.push tag_object
        #     # console.log right_tag_cloud
        #     right_tag_cloud =  _.sortBy(right_tag_cloud, 'count')
        #     wrong_tag_cloud = _.sortBy(wrong_tag_cloud, 'count')
        #     right_tag_cloud = right_tag_cloud.reverse()
        #     wrong_tag_cloud = wrong_tag_cloud.reverse()
        #     right_tag_cloud = right_tag_cloud[..10]
        #     wrong_tag_cloud = wrong_tag_cloud[..10]
        #     # right_tag_cloud = _.countBy(all_right_tags, (tag)-> tag)
        #     # wrong_tag_cloud = _.countBy(all_wrong_tags, (tag)-> tag)

        #     Meteor.users.update user_id,
        #         $set:
        #             right_tag_list:right_tag_list
        #             wrong_tag_list:wrong_tag_list
        #             right_tag_cloud:right_tag_cloud
        #             wrong_tag_cloud:wrong_tag_cloud



        calc_user_stats: (user_id)->
            user = Meteor.users.findOne user_id
            unless user
                user = Meteor.users.findOne username
            user_id = user._id
            
            # console.log classroom
            # student_stats_doc = Docs.findOne
            #     model:'student_stats'
            #     user_id: user_id
            #
            # unless student_stats_doc
            #     new_stats_doc_id = Docs.insert
            #         model:'student_stats'
            #         user_id: user_id
            #     student_stats_doc = Docs.findOne new_stats_doc_id

            # debits = Docs.find({
            #     model:'debit'
            #     amount:$exists:true
            #     _author_id:user_id})
            # debit_count = debits.count()
            # total_debit_amount = 0
            # for debit in debits.fetch()
            #     total_debit_amount += debit.amount

            # console.log 'total debit amount', total_debit_amount

            viewed_docs = Docs.find({
                model:'post'
                _author_id: user_id
                viewer_ids:$exists:true
            })
            viewed_docs_count = viewed_docs.count()
            console.log 'viewed docs count', viewed_docs_count
            
            total_views_amount = 0
            for post in viewed_docs.fetch()
                # if post.amount
                total_views_amount += post.viewer_ids.length
            
            
            tips_out = Docs.find({
                model:'tip'
                _author_id: user_id
            })
            tips_out_count = tips_out.count()
            console.log 'tips out count', tips_out_count
            
            total_tips_out_amount = 0
            for tip in tips_out.fetch()
                if tip.amount
                    total_tips_out_amount += tip.amount
            
            
            tips_in = Docs.find({
                model:'post'
                _author_id: user_id
                # tip_total: $exists: true
            })
            tips_in_count = tips_in.count()
            console.log 'tips in count', tips_in_count
            
            total_tips_in_amount = 0
            for post in tips_in.fetch()
                if post.tip_total
                    total_tips_in_amount += post.tip_total
            
            
            # posts = Docs.find({
            #     model:'post'
            #     _author_id:user_id
            #     # published:true
            # })
            # post_count = posts.count()
            # total_bounty_amount = 0
            # for bounty in bountyed.fetch()
            #     total_bounty_amount += bounty.point_bounty
            
            
            # credits = Docs.find({
            #     model:'debit'
            #     amount:$exists:true
            #     target_id:user_id})
            # credit_count = credits.count()
            # total_credit_amount = 0
            # for credit in credits.fetch()
            #     total_credit_amount += credit.amount

            console.log 'total tips in amount', total_tips_in_amount
            console.log 'total tips out amount', total_tips_out_amount
            tip_balance = total_tips_in_amount - total_tips_out_amount + total_views_amount
            
            console.log 'total tip balance + views', tip_balance
            # average_credit_per_student = total_credit_amount/student_count
            # average_debit_per_student = total_debit_amount/student_count
            # flow_volume = Math.abs(total_credit_amount)+Math.abs(total_debit_amount)
            # flow_volumne =+ total_fulfilled_amount
            # flow_volumne =+ total_bounty_amount
            
            
            # points = total_credit_amount-total_debit_amount+total_fulfilled_amount-total_bounty_amount
            # points =+ total_fulfilled_amount
            # points =- total_bounty_amount
            
            # if total_debit_amount is 0 then total_debit_amount++
            # if total_credit_amount is 0 then total_credit_amount++
            # # debit_credit_ratio = total_debit_amount/total_credit_amount
            # unless total_debit_amount is 1
            #     unless total_credit_amount is 1
            #         one_ratio = total_debit_amount/total_credit_amount
            #     else
            #         one_ratio = 0
            # else
            #     one_ratio = 0
                    
            # dc_ratio_inverted = 1/debit_credit_ratio

            # credit_debit_ratio = total_credit_amount/total_debit_amount
            # cd_ratio_inverted = 1/credit_debit_ratio

            # one_score = total_bandwith*dc_ratio_inverted

            Meteor.users.update user_id,
                $set:
                    points:tip_balance
                    # credit_count: credit_count
                    # debit_count: debit_count
                    # total_credit_amount: total_credit_amount
                    # total_debit_amount: total_debit_amount
                    # flow_volume: flow_volume
                    # points:points
                    # one_ratio: one_ratio
                    # total_fulfilled_amount:total_fulfilled_amount
                    # fulfilled_count:fulfilled_count
                    
                    
if Meteor.isServer
    Meteor.publish 'user_child_referrals', (username)->
        user = Meteor.users.findOne username:username
        Meteor.users.find({
            referrer:user._id
            # _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        
    Meteor.publish 'user_debits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'debit'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        
    Meteor.publish 'user_posts', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'post'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
    Meteor.publish 'user_comments', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'comment'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        