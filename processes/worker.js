import Events from '../lib/events'
import Docker from '../lib/docker'
import S3 from '../lib/s3'

module.exports = function() {

  Events.on('release', function(message) {
    console.log('RELEASE!', message)
  })

  Events.on('push:develop', function(message) {

    Docker().then(function(rpmFiles) {
      console.log('BUILD COMPLETE!')

      Events.emit('rpm:built', rpmFiles)
    })
    .catch(function(error) {
      console.error('Error Executing Docker', error)
    })
  })

  Events.on('rpm:built', function(rpmFiles) {
    console.log('RPM built', rpmFiles)
    /*
      S3.upload(rpmFiles).then(function(resource) {
        console.log('Upload to S3 complete')
      })
    */
  })
}
