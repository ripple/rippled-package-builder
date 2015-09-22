var path           = require('path')
var BridgesExpress = require('bridges-express')
var port           = process.env.PORT || 5000

module.exports = function(models) {

  var server = new BridgesExpress({
    directory: path.join(__dirname, '..'),
    controllers: {
      inject: [models]
    }
  })

  server.listen(port, function() {
    console.log('listening on port', port)
  })
}


