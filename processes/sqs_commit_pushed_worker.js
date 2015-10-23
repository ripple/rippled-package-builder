import SQSWorker from '../lib/SqsWorker'
import Events from '../lib/events'

class Worker extends SQSWorker {

  onMessage(message, done) {

    let commit

    try {
      const git_commit = JSON.parse(message.Body)
      commit = {
        commit_hash: git_commit.after
      }

      switch(git_commit.ref) {
        case 'refs/heads/develop':
          commit.yum_repo = 'ripple-nightly'
          commit.s3_bucket = process.env.S3_BUCKET_NIGHTLY
          commit.branch = 'develop'
          break
        case 'refs/heads/release':
          commit.yum_repo = 'ripple-unstable'
          commit.s3_bucket = process.env.S3_BUCKET_UNSTABLE
          commit.branch = 'release'
          break
        case 'refs/heads/master':
          commit.yum_repo = 'ripple-stable'
          commit.s3_bucket = process.env.S3_BUCKET_STABLE
          commit.branch = 'master'
          break
        default:
          done()
      }
    } catch(error) {
      console.log("error", error)
      done()
    }

    Events.emit('sqs:rippled:commit:pushed', commit)

    done()
  }
}

module.exports = function() {
  new Worker({
    QueueUrl: process.env.SQS_QUEUE_COMMIT_PUSHED,
    region: process.env.SQS_REGION
  }).start()
}

