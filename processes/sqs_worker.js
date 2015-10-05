import SQSWorker from '../lib/SqsWorker'
import Events from '../lib/events'

const QUEUE_URL = 'https://sqs.us-west-2.amazonaws.com/356003847803/rippled-rpm-uploaded'

class RPMFile {
  constructor(message) {

    return {
      bucket: JSON.parse(message.Body).Records[0].s3.bucket.name,
      key: JSON.parse(message.Body).Records[0].s3.object.key
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

    Events.emit('s3:rpm:uploaded', rpmFile)

    done()
  }
}

module.exports = function() {
  new Worker({
    QueueUrl: QUEUE_URL,
    region: 'us-west-2'
  }).start()
}

