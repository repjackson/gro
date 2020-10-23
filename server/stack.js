Meteor.methods({
  search_stack: function(query) {
    var request = require('request');
    
    var url = 'https://api.stackexchange.com/2.2/sites';
    // var url = 'http://api.stackexchange.com/2.1/questions?pagesize=100&fromdate=1356998400&todate=1359676800&order=desc&min=0&sort=votes&tagged=javascript&site=stackoverflow';
    
    request.get({ url: url, headers: {'accept-encoding': 'gzip'}, gzip: true }, function(error, response, body) {
        console.log(body); // not gibberish
    });
    // console.log('searching stack for', typeof query, query);
    // return HTTP.get("https://api.stackexchange.com/2.2/sites", {
    //   headers: {
    //     'Accept-Encoding': 'gzip'
    //   }
    // }, function(err, res) {});
  }
});
