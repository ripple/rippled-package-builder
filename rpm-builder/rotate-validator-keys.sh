#!/bin/bash

if [ -z $1 ]; then
  echo "rotate-validator-keys.sh <master-secret>"
  exit 1
fi

MASTER_SECRET=$1

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

if [ "$VALIDATION_PUBLIC_KEY" == "none" ]; then
  echo "rippled is not configured as a validator"
  echo "Configure with /opt/ripple/bin/configure-validator"
  exit 1
fi

HAS_MANIFEST=`/opt/ripple/bin/rippled server_info -q | \
  python -c 'import json,sys;obj=json.load(sys.stdin); \
  print "validation_manifest" in obj["result"]["info"]'`

if [ "$HAS_MANIFEST" == "False" ]; then
  echo "Cannot rotate validator keys"
  echo "Configure with /opt/ripple/bin/configure-validator"
  exit 1
fi

MASTER_PUBLIC_KEY=`/opt/ripple/bin/rippled server_info -q | \
  python -c 'import json,sys;obj=json.load(sys.stdin); \
  print obj["result"]["info"]["validation_manifest"]["master_key"]'`

SEQUENCE=`/opt/ripple/bin/rippled server_info -q | \
  python -c 'import json,sys;obj=json.load(sys.stdin); \
  print obj["result"]["info"]["validation_manifest"]["seq"]'`

# Generate master keys
MASTER_KEYS=`/opt/ripple/bin/manifest create $MASTER_SECRET`
if [ $? -ne 0 ]; then
  echo "Error generating master keys. Does /opt/ripple/bin/manifest exist?"
  exit 1
fi

if [[ $MASTER_KEYS =~ n([rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz]){51} ]]
then
  if [ "$MASTER_PUBLIC_KEY" != "${BASH_REMATCH[0]}" ]
  then
    echo "Private key does not match configured master public key"
    exit 1
  fi
else
  echo "Error verifying master validator key"
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
MANIFEST=`/opt/ripple/bin/manifest sign $((SEQUENCE + 1)) \
  $VALIDATOR_PUBLIC_KEY $MASTER_SECRET`
if [ $? -ne 0 ]; then
  echo "Error signing new manifest"
  exit 1
fi

# Replace validation_seed
sed -i "/\[validation_seed\]/{n;s/.*/$VALIDATION_SEED/}" \
  /etc/opt/ripple/rippled.cfg

# Remove old validation_manifest
sed -i "/\[validation_manifest\]/,/\[.*\]/{//!d}" /etc/opt/ripple/rippled.cfg

# Add new validation_manifest
MANIFEST=`echo "${MANIFEST/\[validation_manifest\]$'\n'/}"`
MANIFEST=`echo ${MANIFEST//$'\n'/'\\n'}`
sed -i "/\[validation_manifest\]/a$MANIFEST\n" /etc/opt/ripple/rippled.cfg

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
Successfully rotated validator ephemeral keys
EOF

exit 0
