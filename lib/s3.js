import AWS from 'aws-sdk'

AWS.config.region = 'ap-southeast-1';

const S3_BUCKET = new AWS.S3({params: {Bucket: 'rpm-builder-test'}})

export function upload(filesArray) {

  return Promise.resolve('https://bucket.s3.amazon.com/someartifact')
}

