if Meteor.isClient
    @selected_tags = new ReactiveArray []

    Template.cloud.onCreated ->
        @autorun -> Meteor.subscribe('tags', selected_tags.array(), Template.currentData().filter, Template.currentData().limit)

    Template.cloud.helpers
        all_tags: ->
            # doc_count = Docs.find().count()
            # if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()
            results.find(model:'subreddit_tag')
        tag_cloud_class: ->
            button_class = switch
                when @index <= 10 then 'big'
                when @index <= 20 then 'large'
                when @index <= 30 then ''
                when @index <= 40 then 'small'
                when @index <= 50 then 'tiny'
            return button_class


        selected_tags: ->
            # model = 'event'
            selected_tags.array()



    Template.cloud.events
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()

        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_tags.pop()




if Meteor.isServer
    Meteor.publish 'tags', (selected_tags, filter, limit)->
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if filter then match.model = filter
        # if limit
        #     calc_limit = limit
        # else
        #     calc_limit = 20
        cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]


        cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'subreddit_tag'

        self.ready()