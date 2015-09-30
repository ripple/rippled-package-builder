import {spawn, exec} from 'child_process'

const COMMAND = `sudo docker run -e "AWS_ACCESS_KEY_ID=${process.env.AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${process.env.AWS_SECRET_ACCESS_KEY}" -e "RIPPLED_BRANCH=release" rippled-rpm-builder`

export function BuildRPM() {
  console.log('SPAWING DOCKER', COMMAND)
  let docker = exec(COMMAND)

  docker.on('error', function(error) {
    console.log('docker error', error)
  })
}

