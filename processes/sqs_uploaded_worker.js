import SQSWorker from '../lib/SqsWorker'
import Events from '../lib/events'

class RPMFile {
  constructor(message) {
    const rpm_message = JSON.parse(message.Body)

    return {
      s3_bucket: rpm_message.s3_bucket,
      s3_key: rpm_message.s3_key,
      commit_hash: rpm_message.commit_hash,
      commit_signer: rpm_message.commit_signer,
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

    Events.emit('sqs:rpm:uploaded', rpmFile)

    done()
  }
}

module.exports = function() {
  new Worker({
    QueueUrl: process.env.SQS_QUEUE_UPLOADED,
    region: process.env.SQS_REGION
  }).start()
}

