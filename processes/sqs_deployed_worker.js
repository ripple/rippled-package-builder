import SQSWorker from '../lib/SqsWorker'
import Events from '../lib/events'

class RPMFile {
  constructor(message) {
    const rpm_message = JSON.parse(message.Body)

    return {
      commit_hash: rpm_message.commit_hash,
      md5sum: rpm_message.md5sum,
      rippled_version: rpm_message.rippled_version,
      commit_signer: rpm_message.commit_signer,
      yum_repo: rpm_message.yum_repo
    }
  }
}

class Worker extends SQSWorker {

  onMessage(message, done) {

    try {
      let rpmFile = new RPMFile(message)
      Events.emit('sqs:rpm:deployed', rpmFile)
    } catch(error) {
      console.log("error", error)
    }

    done()
  }
}

module.exports = function() {
  new Worker({
    QueueUrl: process.env.SQS_QUEUE_DEPLOYED,
    region: process.env.SQS_REGION
  }).start()
}

