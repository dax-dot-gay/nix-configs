#!/bin/bash

rm -rf /shared/systems/access/login-attempt.json
echo "$SFTPGO_LOGIND_USER" > /shared/systems/access/login-attempt.json
USER_ID="$(/run/current-system/sw/bin/jq .id /shared/systems/access/login-attempt.json)"
USER_NAME="$(/run/current-system/sw/bin/jq .username /shared/systems/access/login-attempt.json)"

if [$USER_ID -eq 0 && $SFTPGO_LOGIND_PROTOCOL == "OIDC"]; then
    echo '{"status": 1, "username": "$USER_NAME"}'
else
    echo ""
fi

rm -rf /shared/systems/access/login-attempt.json