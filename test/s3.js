require('../processes/worker')
import S3 from '../lib/s3'

S3.upload().then(function(result){ 
  console.log('result', result)
})

