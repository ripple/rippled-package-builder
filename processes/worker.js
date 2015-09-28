var Events = require('../lib/events')

module.exports = function() {

  Events.on('release', function(message) {

    console.log('RELEASE!', message)
  })

  Events.on('merge', function(message) {

    console.log('MERGED TO DEVELOP!', message)
  })

  Events.on('push', function(message) {

    console.log('PUSHED!', message)
  })
}

