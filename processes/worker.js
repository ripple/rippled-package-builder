var Releases = require('../lib/releases')
var DevelopBranch = require('../lib/develop_branch')

module.exports = function() {

  Releases.on('release', function(message) {

    console.log('RELEASE!', message)
  })

  DevelopBranch.on('merge', function(message) {

    console.log('MERGED TO DEVELOP!', message)
  })
}

