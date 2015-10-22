import Events from '../lib/events'
import {RPMFromCommit, DeployRPMToStaging, TestStagingRPM} from '../lib/docker'
import {postToSlack} from '../lib/slack'

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
      RPMFromCommit(commitHash, process.env.S3_BUCKET_STABLE, 'ripple-stable')
      postToSlack(`I am now building a rippled RPM from the master branch commit ${commitHash}`)
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

