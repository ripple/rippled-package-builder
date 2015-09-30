import AWS from 'aws-sdk'

const s3 = new AWS.S3()
const BUCKET = 'rpm-builder-test'

export function RPMBuilds() {

  console.log("get builds")

  return new Promise(function(resolve, reject) {
    s3.listObjects({
      Bucket: BUCKET
    }, function(err, data) {
      console.log(err, data)
      if (err) {
        reject(err)
      } else {
        resolve(data) 
      }
    })
  })
}

