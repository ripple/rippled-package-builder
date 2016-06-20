#!/bin/bash

# parseJSON <field>
# reads JSON from stdin
# returns value at <field>
function parseJSON {
  PARSE_SCRIPT=`printf "import json,sys;obj=json.load(sys.stdin); \
  print obj%s" $1`
  VALUE=`cat | python -c "$PARSE_SCRIPT" 2>$1` || exit 1

  echo "$VALUE"
}

if /opt/ripple/bin/rippled -q server_info | \
  grep -q 'no response from server'
then
  echo "rippled server is not running"
  exit 1
fi

# Check for validation key
VALIDATION_PUBLIC_KEY=`/opt/ripple/bin/rippled -q server_info | \
  parseJSON '["result"]["info"]["pubkey_validator"]'` || \
  { echo "Error parsing server_info response"; exit 1; }
if [ "$VALIDATION_PUBLIC_KEY" != "none" ]; then
  echo "rippled already configured as a validator"
  exit 1
fi

# Generate master keys
MASTER_KEYS=`/opt/ripple/bin/manifest create` || \
  { echo "Error generating master keys. Does /opt/ripple/bin/manifest exist?"
  exit 1; }

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
  parseJSON '["result"]["validation_seed"]'` || \
  { echo "Error parsing validation_create response"; exit 1; }
VALIDATOR_PUBLIC_KEY=`echo $VALIDATOR_KEYS | \
  parseJSON '["result"]["validation_public_key"]'` || \
  { echo "Error parsing validation_create response"; exit 1; }

# Generate and sign validator manifest
MANIFEST=`/opt/ripple/bin/manifest sign 1 $VALIDATOR_PUBLIC_KEY $MASTER_SECRET` || \
  { echo "Error signing manifest:
/opt/ripple/bin/manifest 1 $VALIDATOR_PUBLIC_KEY $MASTER_SECRET"; \
  exit 1; }

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

EPHEMERAL_PUBLIC_KEY=`/opt/ripple/bin/rippled -q server_info | \
  parseJSON '["result"]["info"]["pubkey_validator"]'` || \
  { echo "Error parsing server_info response"; exit 1; }

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
