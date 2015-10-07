var path           = require('path')
var BridgesExpress = require('bridges-express')
var port           = process.env.PORT || 5000
var app            = require('../lib/app')

module.exports = function() {

  var server = new BridgesExpress({
    app: app,
    directory: path.join(__dirname, '..')
  })

  server.listen(port, function() {
    console.log('listening on port', port)
  })

  return app
}


