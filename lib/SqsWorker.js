import AWS from 'aws-sdk'

export default class SQSWorker {

  constructor(options) {
    this.QueueUrl = options.QueueUrl
    this.sqs = new AWS.SQS({
      region: options.region || 'us-east-1'
    })
  }

  onMessage(message, done) {
    console.log(message)
    done()
  }

  start() {
    var worker = this

    function getNextMessage() {
      worker.sqs.receiveMessage({
        QueueUrl: worker.QueueUrl,
        MaxNumberOfMessages: 1
      }, (err, data) => {
        if (err) {
          throw err
        } else {
          if (data.Messages) {
            const message = data.Messages[0]
            worker.onMessage(message, () => {
              worker.sqs.deleteMessage({
                QueueUrl: worker.QueueUrl,
                ReceiptHandle: message.ReceiptHandle
              }, function(err, resp) {
                if (err) { throw err }
                console.log('message deleted')
                process.nextTick(() => {
                  getNextMessage()
                })
              })
            })
          } else {
            process.nextTick(() => {
              setTimeout(function() {
                getNextMessage()
              }, 1000)
            })
          }
        }
      })
    }

    getNextMessage()
  }
}


