Meteor.methods 
    search_stack: (query) ->
        console.log('searching stack for', typeof query, query);
        request = require('request')
        # var url = 'https://api.stackexchange.com/2.2/sites';
        url = 'http://api.stackexchange.com/2.1/questions?pagesize=1&fromdate=1356998400&todate=1359676800&order=desc&min=0&sort=votes&tagged=javascript&site=stackoverflow'
        request.get {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }, (error, response, body) ->
            console.log body
            # for itemeach body.items
            #   tags
            #   owner
            #   is_answered
        # return
        # # return HTTP.get("https://api.stackexchange.com/2.2/sites", {
        # #   headers: {
        # #     'Accept-Encoding': 'gzip'
        # #   }
        # # }, function(err, res) {});
        # return