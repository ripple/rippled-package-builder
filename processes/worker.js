import Events from '../lib/events'
import {BuildRPM} from '../lib/docker'

module.exports = function() {

  Events.on('release', function(message) {
    console.log('RELEASE!', message)
  })

  Events.on('push:develop', function(message) {
    BuildRPM()
  })
}
