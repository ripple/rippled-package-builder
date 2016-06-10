#!/bin/bash

if /opt/ripple/bin/rippled -q server_info | \
  grep -q 'no response from server'
then
  echo "rippled server is not running"
  exit 1
fi

# Check for validation key
VALIDATION_PUBLIC_KEY=`/opt/ripple/bin/rippled server_info -q | \
  python -c 'import json,sys;obj=json.load(sys.stdin); \
  print obj["result"]["info"]["pubkey_validator"]'`
if [ "$VALIDATION_PUBLIC_KEY" != "none" ]; then
  echo "rippled already configured as a validator"
  exit 1
fi

# Generate master keys
MASTER_KEYS=`/opt/ripple/bin/manifest create`
if [ $? -ne 0 ]; then
  echo "Error generating master keys. Does /opt/ripple/bin/manifest exist?"
  exit 1
fi

if [[ $MASTER_KEYS =~ n([rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz]){51} ]]
then
  MASTER_PUBLIC_KEY=${BASH_REMATCH[0]}
fi

if [[ $MASTER_KEYS =~ p([rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz]){50} ]]
then
  MASTER_SECRET=${BASH_REMATCH[0]}
fi

if [ -z "$MASTER_PUBLIC_KEY" ] || \
   [ -z "$MASTER_SECRET" ]
then
  echo "/opt/ripple/bin/manifest failed to generate master validator keys"
  exit 1
fi

# Generate ephemeral validation keys
VALIDATOR_KEYS=`/opt/ripple/bin/rippled validation_create -q`
VALIDATION_SEED=`echo $VALIDATOR_KEYS | \
  python -c 'import json,sys;obj=json.load(sys.stdin); \
  print obj["result"]["validation_seed"]'`
VALIDATOR_PUBLIC_KEY=`echo $VALIDATOR_KEYS | \
  python -c 'import json,sys;obj=json.load(sys.stdin); \
  print obj["result"]["validation_public_key"]'`

# Generate and sign validator manifest
MANIFEST=`/opt/ripple/bin/manifest sign 1 $VALIDATOR_PUBLIC_KEY $MASTER_SECRET`
if [ $? -ne 0 ]; then
  echo "Error signing manifest:
/opt/ripple/bin/manifest 1 $VALIDATOR_PUBLIC_KEY $MASTER_SECRET"
  exit 1
fi

echo "
[validation_seed]
$VALIDATION_SEED

$MANIFEST
" >> /etc/opt/ripple/rippled.cfg

systemctl restart rippled.service

# Wait for rippled to start up
END=$((SECONDS + 20))
while /opt/ripple/bin/rippled -q server_info | \
  grep -q 'no response from server'
do
  if [ $SECONDS -gt $END ]; then
    echo "rippled failed to restart"
    exit 1
  fi
  sleep 1
done

EPHEMERAL_PUBLIC_KEY=`/opt/ripple/bin/rippled server_info -q | \
  python -c 'import json,sys;obj=json.load(sys.stdin); \
  print obj["result"]["info"]["pubkey_validator"]'`

if [ "$VALIDATOR_PUBLIC_KEY" != "$EPHEMERAL_PUBLIC_KEY" ]
then
  echo "Error ephemeral key does not match signed manifest"
  exit 1
fi

cat << EOF
rippled is now running as a validating server.
master public key: $MASTER_PUBLIC_KEY
master secret: $MASTER_SECRET <-- Keep this PRIVATE and save in a secure place
EOF

exit 0
