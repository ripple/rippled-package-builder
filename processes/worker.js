import Events from '../lib/events'
import {RPMFromCommit, RPMFromTag, DeployRPMToStaging} from '../lib/docker'

module.exports = function() {

  Events.on('push:develop', function(message) {
    // trigger build for "nightly" yum repostory
    const commitHash = message.after

    if (commitHash) {
      RPMFromCommit(commitHash)
    } else {
      console.error('no commit hash')
    }
  })

  Events.on('push:release', function(message) {
    // trigger build for "unstable" yum repostory
  })

  Events.on('push:master', function(message) {
    // trigger build for "stable" yum repostory
  })

  Events.on('s3:rpm:uploaded', function(message) {

    DeployRPMToStaging(message.bucket, message.key)
  })
}

