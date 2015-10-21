import Events from '../lib/events'
import {RPMFromCommit, DeployRPMToStaging, TestStagingRPM} from '../lib/docker'

module.exports = function() {

  Events.on('push:develop', function(message) {
    // trigger build for "nightly" yum repostory
  })

  Events.on('push:release', function(message) {
    // trigger build for "unstable" yum repostory
  })

  Events.on('push:master', function(message) {
    // trigger build for "stable" yum repostory
    const commitHash = message.after

    if (commitHash) {
      RPMFromCommit(commitHash)
    } else {
      console.error('no commit hash')
    }
  })

  Events.on('sqs:rpm:uploaded', function(message) {

    DeployRPMToStaging(message)
  })

  Events.on('sqs:rpm:deployed', function(message) {

    TestStagingRPM(message)
  })
}

