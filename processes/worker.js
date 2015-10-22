import Events from '../lib/events'
import {BuildRPMFromCommit, DeployRPMToStaging, TestStagingRPM} from '../lib/docker'
import {postToSlack} from '../lib/slack'

module.exports = function() {

  Events.on('sqs:rippled:commit:pushed', function(message) {
    BuildRPMFromCommit(message.commit_hash, message.s3_bucket, message.yum_repo)
    postToSlack(`I am now building a rippled RPM from the ${message.branch} branch commit ${message.commit_hash}`)
  })

  Events.on('sqs:rpm:uploaded', function(message) {
    postToSlack(`I built and uploaded a rippled RPM from the commit ${message.commit_hash} to https://s3-ap-southeast-1.amazonaws.com/${message.s3_bucket}/${message.s3_key}`)

    DeployRPMToStaging(message)
  })

  Events.on('sqs:rpm:deployed', function(message) {

    TestStagingRPM(message)
  })
}

