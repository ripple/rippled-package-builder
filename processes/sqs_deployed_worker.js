import SQSWorker from '../lib/SqsWorker'
import Events from '../lib/events'

const QUEUE_URL = 'https://sqs.us-west-2.amazonaws.com/356003847803/rippled-rpm-deployed-staging'

class Worker extends SQSWorker {

  onMessage(message, done) {

    var yumRepo

    try {
      yumRepo = JSON.parse(message.Body).repo
    } catch(error) {
      console.log("error", error)
      done()
    }

    Events.emit('s3:rpm:deployed', yumRepo)

    done()
  }
}

module.exports = function() {
  new Worker({
    QueueUrl: QUEUE_URL,
    region: 'us-west-2'
  }).start()
}

