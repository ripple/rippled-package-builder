import {spawn, exec} from 'child_process'

const COMMAND = 'sudo docker run -v $PWD:/opt/rippled-rpm/out -e "RIPPLED_BRANCH=release" rippled-builder'

export default function Docker() {
  return new Promise(function(resolve, reject) {
    console.log('SPAWING DOCKER', COMMAND)
    let docker = exec(COMMAND)

    docker.on('error', function(error) {
      console.log('docker error', error)
    })

    docker.on('exit', function(code) {
      console.log('docker exited', code)
    })

    docker.on('close', function(code) {
      console.log("docker closed", code)

      if (code !== 0) {
        reject()
      } else {
        resolve()
      }
    })
  })
}

