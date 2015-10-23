import Events from '../lib/events'
import {BuildRPMFromCommit, DeployRPMToStaging, TestStagingRPM} from '../lib/docker'
import {postToSlack} from '../lib/slack'

module.exports = function() {

  Events.on('sqs:rippled:commit:pushed', function(message) {
    BuildRPMFromCommit(message.commit_hash, message.s3_bucket, message.yum_repo)
    postToSlack(`I am now building a rippled RPM for commit \`${message.commit_hash}\` from the \`${message.branch}\` branch`)
  })

  Events.on('sqs:rpm:uploaded', function(message) {
    postToSlack(`I built and uploaded the \`rippled-${message.rippled_version}\` RPM from the commit \`${message.commit_hash}\` to https://s3-ap-southeast-1.amazonaws.com/${message.s3_bucket}/${message.s3_key}`)

    DeployRPMToStaging(message)
  })

  Events.on('sqs:rpm:deployed', function(message) {
    postToSlack(`I deployed the \`rippled-${message.rippled_version}\` RPM to the \`${message.yum_repo}\` yum repo on https://test-mirrors.ripple.com\nMD5SUM: \`${message.md5sum}\`\nStarting tests now :rippleguy:`)

    TestStagingRPM(message)
  })

  Events.on('sqs:rpm:tested', function(message) {
    postToSlack(`Tests passed for the \`rippled-${message.rippled_version}\` RPM from the \`${message.yum_repo}\` yum repo! :100: :koolaid:`)
  })

  Events.on('sqs:rpm:failed', function(message) {
    postToSlack(`The \`${message.stage}\` experienced the following error for rippled commit \`${message.commit_hash}\` (\`${message.yum_repo}\`)\n\`${message.error}\` :unimpressedyongsoo:`)
  })
}

