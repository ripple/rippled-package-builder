var Events = require('../lib/events')
var exec   = require('child_process').exec

var INVALID_COMMAND = 'sudo docker run invalid-image'
var COMMAND = 'sudo docker run -v $PWD:/opt/rippled-rpm/out -e "RIPPLED_BRANCH=release" rpm-builder'

function Docker() {
  return new Promise(function(resolve, reject) {
    exec(INVALID_COMMAND, function (error, stdout, stderr) {
        if (error) {
          reject(error)
        } else {
          resolve(stdout)
        }
    })
  })
}

module.exports = function() {

  Events.on('release', function(message) {
    console.log('RELEASE!', message)
  })

  Events.on('push:develop', function(message) {

    console.log('PUSHED TO DEVELOP!', message)

    Docker().then(function(result) {
      console.log('Executed Docker', result)
    })
    .catch(function(error) {
      console.error('Error Executing Docker', error)
    })
  })
}
