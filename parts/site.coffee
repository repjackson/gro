if Meteor.isClient
    Router.route '/site/:site', (->
        @layout 'layout'
        @render 'site_page'
        ), name:'site_page'
    
    Router.route '/site/:site/doc/:doc_id', (->
        @layout 'layout'
        @render 'stack_page'
        ), name:'stack_page'
    
    Template.site_page.onCreated ->
        @autorun => Meteor.subscribe 'site_by_param', Router.current().params.site
        @autorun => Meteor.subscribe 'site_tags',
            selected_tags.array()
            Router.current().params.site
            
        @autorun => Meteor.subscribe 'stack_docs_by_site', 
            Router.current().params.site
            selected_tags.array()
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
    Template.site_page.helpers
        selected_tags: -> selected_tags.array()
        site_tags: -> results.find(model:'site_tag')
        current_site: ->
            Docs.findOne
                model:'stack_site'
                api_site_parameter:Router.current().params.site
        site_questions: ->
            Docs.find {
                model:'stack'
                site:Router.current().params.site
            },
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                limit:Session.get('limit')
    Template.site_page.events
        'click .sort_timestamp': (e,t)-> Session.set('sort_key','_timestamp')
        'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
        'click .toggle_detail': (e,t)-> 
            Session.set('view_detail',!Session.get('view_detail'))
        'click .sort_up': (e,t)-> Session.set('sort_direction',1)
        'click .limit_10': (e,t)-> Session.set('limit',10)
        'click .limit_1': (e,t)-> Session.set('limit',1)
        'keyup .search_site': (e,t)->
            # search = $('.search_site').val().toLowerCase().trim()
            search = $('.search_site').val().trim()
            if e.which is 13
                # window.speechSynthesis.cancel()
                # console.log search
                if search.length > 0
                    site = 
                        Docs.findOne
                            model:'stack_site'
                            api_site_parameter:Router.current().params.site
                    if site
                        Meteor.call 'search_stack', site.api_site_parameter, search, ->

if Meteor.isServer
    Meteor.publish 'stack_docs_by_site', (
        site
        selected_tags
        sort_key
        sort_direction
        limit
    )->
        console.log 'site', site
        console.log 'sort_key', sort_key
        console.log 'sort_direction', sort_direction
        console.log 'limit', limit
        # site = Docs.findOne
        #     model:'stack_site'
        #     api_site_parameter:site
        match = {
            model:'stack'
            site:site
            }
        if selected_tags.length > 0 then match.tags = $in:selected_tags
        if site
            Docs.find match, 
                limit:10
                # sort:
                #     "#{sort_key}":sort_direction
                # limit:limit
    Meteor.publish 'site_tags', (
        selected_tags
        site
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'stack'
            site:site
            }
        # console.log 'tags', selected_tags
        if selected_tags.length > 0 then match.tags = $in:selected_tags
        site_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            # { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', tag_cloud
        console.log 'tag match', match
        site_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'site_tag'
        self.ready()
