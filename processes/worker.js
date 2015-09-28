var releases = require('../lib/releases')

module.exports = function() {

  releases.on('release', function(message) {

    console.log('RELEASE!', message)
  })
}


