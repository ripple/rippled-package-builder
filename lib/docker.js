import {spawn, exec} from 'child_process'

const DOCKER_RUN = `sudo docker run -e "AWS_ACCESS_KEY_ID=${process.env.AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${process.env.AWS_SECRET_ACCESS_KEY}"` 

function spawnDocker(command) {

  let docker = exec(command)

  console.log('docker:run', command)

  docker.on('error', function(error) {
    console.log('docker error', error)
  })
}

export function RPMFromTag(releaseTag) {
  const image = 'rippled-rpm-builder'

  spawnDocker(`${DOCKER_RUN} -e "RELEASE_TAG=${releaseTag}" ${image}`)
}

export function DeployRPMToStaging(s3Bucket, s3Key) {
  const image = 'rpm-staging-deployer'

  spawnDocker(`${DOCKER_RUN} -e "S3_BUCKET=${s3Bucket}" -e "S3_KEY=${s3Key}" ${image}`)
}

export function RPMFromCommit(commitHash) {
  const image = 'rippled-rpm-builder'

  spawnDocker(`${DOCKER_RUN} -e "COMMIT_HASH=${commitHash}" ${image}`)
}

