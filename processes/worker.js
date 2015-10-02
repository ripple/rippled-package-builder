import Events from '../lib/events'
import {RPMFromCommit, RPMFromTag, DeployRPMToStaging} from '../lib/docker'

module.exports = function() {

  Events.on('release', function(message) {
    const releaseTag = message.release.tag_name

    RPMFromTag(releaseTag)
  })

  Events.on('push:develop', function(message) {
    const commitHash = message.after

    RPMFromCommit(commitHash)
  })

  Events.on('s3:rpm:uploaded', function(message) {

    DeployRPMToStaging(message.bucket, message.key)
  })
}

