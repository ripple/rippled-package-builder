import {spawn, exec} from 'child_process'

const DOCKER_RUN = `docker run -e "AWS_ACCESS_KEY_ID=${process.env.AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${process.env.AWS_SECRET_ACCESS_KEY}" -e "SQS_REGION=${process.env.SQS_REGION}" -e "SQS_QUEUE_FAILED=${process.env.SQS_QUEUE_FAILED}"`

function spawnDocker(command) {

  let docker = exec(command)

  console.log('docker:run', command)

  docker.on('error', function(error) {
    console.log('docker error', error)
  })
}

export function RPMFromCommit(commitHash, s3Bucket, yumRepo) {
  const image = 'rippled-rpm-builder'

  spawnDocker(`${DOCKER_RUN} -e "COMMIT_HASH=${commitHash}" -e "YUM_REPO=${yumRepo}" -e "GPG_PASSPHRASE=${process.env.GPG_PASSPHRASE}" -e "S3_REGION=${process.env.S3_REGION}" -e "S3_BUCKET=${s3Bucket}" -e "SQS_QUEUE_UPLOADED=${process.env.SQS_QUEUE_UPLOADED}" ${image}`)
}

export function DeployRPMToStaging(rpm) {
  const image = 'rippled-rpm-deployer'
  const RPM = `-e "COMMIT_HASH=${rpm.commit_hash}" -e "COMMIT_SIGNER=${rpm.commit_signer}" -e "MD5SUM=${rpm.md5sum}" -e "RIPPLED_VERSION=${rpm.rippled_version}" -e "YUM_REPO=${rpm.yum_repo}"`

  spawnDocker(`${DOCKER_RUN} -e "S3_REGION=${process.env.S3_REGION}" -e "S3_BUCKET=${rpm.s3_bucket}" -e "S3_KEY=${rpm.s3_key}" ${RPM} -e "SQS_QUEUE_DEPLOYED=${process.env.SQS_QUEUE_DEPLOYED}" ${image}`)
}

export function TestStagingRPM(rpm) {
  const image = 'rippled-rpm-tester'
  const RPM = `-e "COMMIT_HASH=${rpm.commit_hash}" -e "COMMIT_SIGNER=${rpm.commit_signer}" -e "MD5SUM=${rpm.md5sum}" -e "RIPPLED_VERSION=${rpm.rippled_version}" -e "YUM_REPO=${rpm.yum_repo}"`

  spawnDocker(`${DOCKER_RUN} ${RPM} -e "SQS_QUEUE_TESTED=${process.env.SQS_QUEUE_TESTED}" ${image}`)
}
