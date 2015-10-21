import SQSWorker from '../lib/SqsWorker'
import Events from '../lib/events'

const QUEUE_URL = 'https://sqs.us-west-2.amazonaws.com/356003847803/rippled-rpm-deployed-staging'

class RPMFile {
  constructor(message) {
    const rpm_message = JSON.parse(message.Body)

    return {
      commit_hash: rpm_message.commit_hash,
      md5sum: rpm_message.md5sum,
      rippled_version: rpm_message.rippled_version,
      yum_repo: rpm_message.yum_repo
    }
  }
}

class Worker extends SQSWorker {

  onMessage(message, done) {

    var rpmFile

    try {
      rpmFile = new RPMFile(message)
    } catch(error) {
      console.log("error", error)
      done()
    }

    Events.emit('sqs:rpm:deployed', rpmFile)

    done()
  }
}

module.exports = function() {
  new Worker({
    QueueUrl: QUEUE_URL,
    region: 'us-west-2'
  }).start()
}

