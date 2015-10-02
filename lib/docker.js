import {spawn, exec} from 'child_process'

const DOCKER_RUN = `sudo docker run -e "AWS_ACCESS_KEY_ID=${process.env.AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${process.env.AWS_SECRET_ACCESS_KEY}"` 
const IMAGE_NAME = 'rippled-rpm-builder'

export function RPMFromTag(releaseTag) {

  let  COMMAND = `${DOCKER_RUN} -e "RELEASE_TAG=${releaseTag}" ${IMAGE_NAME}`

  let docker = exec(COMMAND)

  console.log('docker:run', IMAGE_NAME, `release:${RELEASE_TAG}`)

  docker.on('error', function(error) {
    console.log('docker error', error)
  })
}

export function DeployRPMToStaging(message) {

  console.log('DEPLOY FROM S3 TO STAGING', message)
}

export function RPMFromCommit(commitHash) {

  let  COMMAND = `${DOCKER_RUN} -e "COMMIT_HASH=${commitHash}" ${IMAGE_NAME}`

  console.log('docker:run', IMAGE_NAME, `commit:${COMMIT_HASH}`)

  let docker = exec(COMMAND)

  docker.on('error', function(error) {
    console.log('docker error', error)
  })
}

