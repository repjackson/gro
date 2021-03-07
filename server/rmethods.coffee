request = require('request')
rp = require('request-promise');
Meteor.methods
    search_reddit: (query)->
        @unblock()
        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/search.json?q=#{query}&limit=100&include_facets=false&raw_json=1"
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
        HTTP.get url,(err,res)=>
            if res.data.data.dist > 1
                _.each(res.data.data.children, (item)=>
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        added_tags = [query]
                        # added_tags = [query]
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.subreddit.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        added_tags = _.flatten(added_tags)
                        reddit_post =
                            reddit_id: data.id
                            url: data.url
                            domain: data.domain
                            comment_count: data.num_comments
                            permalink: data.permalink
                            ups: data.ups
                            title: data.title
                            subreddit: data.subreddit
                            group:data.subreddit
                            group_lowered:data.subreddit.toLowerCase()
                            # root: query
                            # selftext: false
                            # thumbnail: false
                            tags: added_tags
                            model:'rpost'
                            # source:'reddit'
                            data:data
                        existing = Docs.findOne 
                            model:'rpost'
                            url:data.url
                        if existing
                            # if Meteor.isDevelopment
                            #     console.log 'existing', existing
                            # if typeof(existing.tags) is 'string'
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update existing._id,
                                $addToSet: tags: $each: added_tags
                                $set:data:data

                            # Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                        unless existing
                            new_reddit_post_id = Docs.insert reddit_post
                            # if Meteor.isDevelopment
                            #     console.log 'new', new_reddit_post_id
                            # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                Meteor.call 'call_wiki', query, ->        
                )
   

    # get_reddit_post: (doc_id, reddit_id, root)->
    #     @unblock()
    #     doc = Docs.findOne doc_id
    #     if doc.reddit_id
    #         # HTTP.get "http://reddit.com/by_id/t3_#{doc.reddit_id}.json&raw_json=1", (err,res)->
    #         HTTP.get "https://www.reddit.com/comments/#{doc.reddit_id}/.json", (err,res)->
    #             if err
    #                 console.error err
    #             unless err
    #                 rd = res.data[0].data.children[0].data
    #                 Docs.update doc_id,
    #                     $set:
    #                         data: rd
    #                         url: rd.url
    #                         # reddit_image:rd.preview.images[0].source.url
    #                         thumbnail: rd.thumbnail
    #                         subreddit: rd.subreddit
    #                         group:rd.subreddit
    #                         author: rd.author
    #                         domain: rd.domain
    #                         is_video: rd.is_video
    #                         ups: rd.ups
    #                         # downs: rd.downs
    #                         over_18: rd.over_18

                


Meteor.methods
    call_wiki: (query)->
        # term = query.split(' ').join('_')
        # term = query[0]
        console.log 'calling wiki for', query
        @unblock()
        term = query
        # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
        HTTP.get "https://en.wikipedia.org/w/api.php?action=opensearch&generator=searchformat=json&search=#{term}",(err,response)=>
            unless err
                for term,i in response.data[1]
                    url = response.data[3][i]
    
    
                    found_doc =
                        Docs.findOne
                            url: url
                            model:'wikipedia'
                    if found_doc
                        # Docs.update found_doc._id,
                        #     # $pull:
                        #     #     tags:'wikipedia'
                        #     $set:
                        #         title:found_doc.title.toLowerCase()
                        unless found_doc.watson
                            unless found_doc.watson
                                Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                    else
                        new_wiki_id = Docs.insert
                            title:term.toLowerCase()
                            tags:[term.toLowerCase()]
                            source: 'wikipedia'
                            model:'wikipedia'
                            # ups: 1
                            url:url
                        Meteor.call 'call_watson', new_wiki_id, 'url','url', ->

    # search_reddit: (query)->
    #     @unblock()
    #     # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "http://reddit.com/search.json?q=#{query}&limit=30&include_facets=false&raw_json=1"
    #     # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
    #     HTTP.get url,(err,res)=>
    #         if res.data.data.dist > 1
    #             _.each(res.data.data.children, (item)=>
    #                 unless item.domain is "OneWordBan"
    #                     data = item.data
    #                     len = 200
    #                     # if typeof(query) is String
    #                     #     added_tags = [query]
    #                     # else
    #                     added_tags = [query]
    #                     # added_tags = [query]
    #                     # added_tags.push data.domain.toLowerCase()
    #                     # added_tags.push data.subreddit.toLowerCase()
    #                     # added_tags.push data.author.toLowerCase()
    #                     added_tags = _.flatten(added_tags)
    #                     reddit_post =
    #                         reddit_id: data.id
    #                         url: data.url
    #                         domain: data.domain
    #                         comment_count: data.num_comments
    #                         permalink: data.permalink
    #                         ups: data.ups
    #                         title: data.title
    #                         subreddit: data.subreddit
    #                         # root: query
    #                         # selftext: false
    #                         # thumbnail: false
    #                         tags: added_tags
    #                         model:'reddit'
    #                         # source:'reddit'
    #                     existing = Docs.findOne 
    #                         model:'reddit'
    #                         url:data.url
    #                     if existing
    #                         # if Meteor.isDevelopment
    #                         # if typeof(existing.tags) is 'string'
    #                         #     Doc.update
    #                         #         $unset: tags: 1
    #                         Docs.update existing._id,
    #                             $addToSet: tags: $each: added_tags

    #                         Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
    #                     unless existing
    #                         # if Meteor.isDevelopment
    #                         new_reddit_post_id = Docs.insert reddit_post
    #                         # Meteor.users.update Meteor.userId(),
    #                         #     $inc:points:1
    #                         Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
    #             )
   
    # reddit_best: (query)->
    #     @unblock()
        
    #     # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "http://reddit.com/best.json?q=#{query}&nsfw=1&limit=30&include_facets=false&raw_json=1"
    #     # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
    #     HTTP.get url,(err,res)=>
    #         if res.data.data.dist > 1
    #             _.each(res.data.data.children, (item)=>
    #                 unless item.domain is "OneWordBan"
    #                     data = item.data
    #                     len = 200
    #                     # if typeof(query) is String
    #                     #     added_tags = [query]
    #                     # else
    #                     added_tags = [query]
    #                     # added_tags = [query]
    #                     # added_tags.push data.domain.toLowerCase()
    #                     # added_tags.push data.subreddit.toLowerCase()
    #                     # added_tags.push data.author.toLowerCase()
    #                     added_tags = _.flatten(added_tags)
    #                     reddit_post =
    #                         reddit_id: data.id
    #                         url: data.url
    #                         domain: data.domain
    #                         comment_count: data.num_comments
    #                         permalink: data.permalink
    #                         ups: data.ups
    #                         title: data.title
    #                         subreddit: data.subreddit
    #                         # root: query
    #                         # selftext: false
    #                         # thumbnail: false
    #                         tags: added_tags
    #                         model:'reddit'
    #                         # source:'reddit'
    #                     existing = Docs.findOne 
    #                         model:'reddit'
    #                         url:data.url
    #                     if existing
    #                         # if Meteor.isDevelopment
    #                         # if typeof(existing.tags) is 'string'
    #                         #     Doc.update
    #                         #         $unset: tags: 1
    #                         Docs.update existing._id,
    #                             $addToSet: tags: $each: added_tags
    #                         Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
    #                     unless existing
    #                         new_reddit_post_id = Docs.insert reddit_post
    #                         # if Meteor.isDevelopment
    #                         # Meteor.users.update Meteor.userId(),
    #                         #     $inc:points:1
    #                         Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
    #             )
    
    # reddit_new: (query)->
    #     @unblock()
        
    #     # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "http://reddit.com/new.json?q=#{query}&nsfw=1&limit=30&include_facets=false&raw_json=1"
    #     # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
    #     HTTP.get url,(err,res)=>
    #         if res.data.data.dist > 1
    #             _.each(res.data.data.children, (item)=>
    #                 unless item.domain is "OneWordBan"
    #                     data = item.data
    #                     len = 200
    #                     # if typeof(query) is String
    #                     #     added_tags = [query]
    #                     # else
    #                     added_tags = [query]
    #                     # added_tags = [query]
    #                     # added_tags.push data.domain.toLowerCase()
    #                     # added_tags.push data.subreddit.toLowerCase()
    #                     # added_tags.push data.author.toLowerCase()
    #                     added_tags = _.flatten(added_tags)
    #                     reddit_post =
    #                         reddit_id: data.id
    #                         url: data.url
    #                         domain: data.domain
    #                         comment_count: data.num_comments
    #                         permalink: data.permalink
    #                         ups: data.ups
    #                         title: data.title
    #                         subreddit: data.subreddit
    #                         # root: query
    #                         # selftext: false
    #                         # thumbnail: false
    #                         tags: added_tags
    #                         model:'reddit'
    #                         # source:'reddit'
    #                     existing = Docs.findOne 
    #                         model:'reddit'
    #                         url:data.url
    #                     if existing
    #                         # if Meteor.isDevelopment
    #                         # if typeof(existing.tags) is 'string'
    #                         #     Doc.update
    #                         #         $unset: tags: 1
    #                         Docs.update existing._id,
    #                             $addToSet: tags: $each: added_tags
    #                         Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
    #                     unless existing
    #                         new_reddit_post_id = Docs.insert reddit_post
    #                         # if Meteor.isDevelopment
        
    #                         # Meteor.users.update Meteor.userId(),
    #                         #     $inc:points:1
    #                         Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
    #             )
    
            
    # reddit_all: ->
    #     total = 
    #         Docs.find({
    #             model:'reddit'
    #             subreddit: $exists:false
    #         }, limit:100)
    #     total.forEach( (doc)->
    #     for doc in total.fetch()
    #         Meteor.call 'get_reddit_post', doc._id, doc.reddit_id, ->
    #     )


    # get_reddit_post: (doc_id, reddit_id, root)->
    #     @unblock()
    #     doc = Docs.findOne doc_id
    #     if doc.reddit_id
    #         HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json&raw_json=1", (err,res)->
    #             if err then console.error err
    #             else
    #                 rd = res.data.data.children[0].data
    #                 # if rd.is_video
    #                 #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
    #                 # else if rd.is_image
    #                 #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
    #                 # else
    #                 #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
    #                 #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
    #                 #     # Meteor.call 'call_visual', doc_id, ->
    #                 # if rd.selftext
    #                 #     unless rd.is_video
    #                 #         # if Meteor.isDevelopment
    #                 #         Docs.update doc_id, {
    #                 #             $set:
    #                 #                 body: rd.selftext
    #                 #         }, ->
    #                 #         #     Meteor.call 'pull_subreddit', doc_id, url
    #                 # if rd.selftext_html
    #                 #     unless rd.is_video
    #                 #         Docs.update doc_id, {
    #                 #             $set:
    #                 #                 html: rd.selftext_html
    #                 #         }, ->
    #                 #             # Meteor.call 'pull_subreddit', doc_id, url
    #                 # if rd.url
    #                 #     unless rd.is_video
    #                 #         url = rd.url
    #                 #         # if Meteor.isDevelopment
    #                 #         Docs.update doc_id, {
    #                 #             $set:
    #                 #                 reddit_url: url
    #                 #                 url: url
    #                 #         }, ->
    #                 #             # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
    #                 # update_ob = {}
    #                 # if rd.preview
    #                 #     if rd.preview.images[0].source.url
    #                 #         thumbnail = rd.preview.images[0].source.url
    #                 # else
    #                 #     thumbnail = rd.thumbnail
    #                 Docs.update doc_id,
    #                     $set:
    #                         data: rd
    #                         url: rd.url
    #                         # reddit_image:rd.preview.images[0].source.url
    #                         thumbnail: rd.thumbnail
    #                         subreddit: rd.subreddit
    #                         author: rd.author
    #                         domain: rd.domain
    #                         is_video: rd.is_video
    #                         ups: rd.ups
    #                         # downs: rd.downs
    #                         over_18: rd.over_18

        
Meteor.methods
    call_alpha: (query)->
        # @unblock()
        found_alpha = 
            Docs.findOne 
                model:'alpha'
                query:query
        if found_alpha
            target = found_alpha
            # if target.updated
            #     return target
        else
            target_id = 
                Docs.insert
                    model:'alpha'
                    query:query
                    tags:[query]
            target = Docs.findOne target_id       
                   
                    
        HTTP.get "http://api.wolframalpha.com/v1/spoken?i=#{query}&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            if response
                Docs.update target._id,
                    $set:
                        voice:response.content  
            # HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&mag=1&ignorecase=true&scantimeout=3&format=html,image,plaintext,sound&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&mag=1&ignorecase=true&scantimeout=5&format=html,image,plaintext&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
                if response
                    parsed = JSON.parse(response.content)
                    Docs.update target._id,
                        $set:
                            response:parsed  
                            updated:true
