var Releases = require('../lib/Releases')
var DevelopBranch = require('../lib/DevelopBranch')

module.exports = function() {

  Releases.on('release', function(message) {

    console.log('RELEASE!', message)
  })

  DevelopBranch.on('merge', function(message) {

    console.log('MERGED TO DEVELOP!', message)
  })
}

