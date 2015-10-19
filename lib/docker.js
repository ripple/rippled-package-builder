import {spawn, exec} from 'child_process'

const DOCKER_RUN = `docker run -e "AWS_ACCESS_KEY_ID=${process.env.AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${process.env.AWS_SECRET_ACCESS_KEY}"`

function spawnDocker(command) {

  let docker = exec(command)

  console.log('docker:run', command)

  docker.on('error', function(error) {
    console.log('docker error', error)
  })
}

export function RPMFromTag(releaseTag) {
  const image = 'rippled-rpm-builder'

  spawnDocker(`${DOCKER_RUN} -e "RELEASE_TAG=${releaseTag}" -e "GPG_PASSPHRASE=${process.env.GPG_PASSPHRASE}" -e "S3_BUCKET=${process.env.S3_BUCKET}" ${image}`)
}

export function RPMFromCommit(commitHash) {
  const image = 'rippled-rpm-builder'

  spawnDocker(`${DOCKER_RUN} -e "COMMIT_HASH=${commitHash}" -e "GPG_PASSPHRASE=${process.env.GPG_PASSPHRASE}" -e "S3_BUCKET=${process.env.S3_BUCKET}" ${image}`)
}

export function DeployRPMToStaging(s3Bucket, s3Key, awsRegion) {
  const image = 'rippled-rpm-deployer'

  spawnDocker(`${DOCKER_RUN} -e "S3_BUCKET=${s3Bucket}" -e "S3_KEY=${s3Key}" -e "AWS_REGION=${awsRegion}" ${AWS_ACCESS} ${image}`)
}

export function TestStagingRPM(yumRepo) {
  const image = 'rippled-rpm-tester'

  spawnDocker(`${DOCKER_RUN} -e "YUM_REPO=${yumRepo}" ${image}`)
}
