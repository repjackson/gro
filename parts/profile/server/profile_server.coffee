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
    
Meteor.publish 'user_posts', (
    username
    skip
    )->
        console.log 'skip', skip
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
    
    
    
Meteor.publish 'friends', ()->
    Meteor.users.find {},
        fields:
            username:1
            tags:1
            profile_image_id:1
            nickname:1    
            
Meteor.publish 'user_edit_alerts', (username)->
    Docs.find
        model:'picture'
            