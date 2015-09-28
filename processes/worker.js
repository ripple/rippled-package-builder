var Events = require('../lib/events')

module.exports = function() {

  Events.on('release', function(message) {

    console.log('RELEASE!', message)
  })

  Events.on('push:develop', function(message) {

    console.log('PUSHED TO DEVELOP!', message)
  })
}

