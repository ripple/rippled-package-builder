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

if [  "$VALIDATION_PUBLIC_KEY" != "none" ]; then
  echo "rippled already configured as a validator"
  exit 1
fi

# Generate validation key
VALIDATION_SEED=`/opt/ripple/bin/rippled validation_create -q | \
  python -c 'import json,sys;obj=json.load(sys.stdin); \
  print obj["result"]["validation_seed"]'`

echo "
[validation_seed]
$VALIDATION_SEED
" >> /etc/opt/ripple/rippled.cfg

systemctl restart rippled.service

# Wait for rippled to start up
while /opt/ripple/bin/rippled -q server_info | \
  grep -q 'no response from server'
do
  sleep 1
done

VALIDATION_PUBLIC_KEY=`/opt/ripple/bin/rippled server_info -q | \
  python -c 'import json,sys;obj=json.load(sys.stdin); \
  print obj["result"]["info"]["pubkey_validator"]'`

if [  "$VALIDATION_PUBLIC_KEY" == "none" ]; then
  echo "validator configuration failed"
  exit 1
fi

cat << EOF
Successfully configured rippled to run as a validating server.
validation public key: $VALIDATION_PUBLIC_KEY
validation seed: $VALIDATION_SEED <-- Keep this PRIVATE and save in a secure place
EOF
