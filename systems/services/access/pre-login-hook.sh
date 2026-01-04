#!/bin/bash

USER_JSON=$SFTPGO_LOGIND_USER;
USER_ID="$(/run/current-system/sw/bin/jq .id '${USER_JSON}')"
USER_NAME="$(/run/current-system/sw/bin/jq .username '${USER_JSON}')"

echo "$SFTPGO_LOGIND_USER" > /shared/attempted_login

if [$USER_ID -eq 0 && $SFTPGO_LOGIND_PROTOCOL == "OIDC"]; then
    echo '{"status": 1, "username": "$USER_NAME"}'
else
    echo ""
fi