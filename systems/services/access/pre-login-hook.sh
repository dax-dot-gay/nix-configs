#!/bin/bash

USER_ID="$(/run/current-system/sw/bin/jq .id $SFTPGO_LOGIND_USER)"
USER_NAME="$(/run/current-system/sw/bin/jq .username $SFTPGO_LOGIND_USER)"

echo "$SFTPGO_LOGIND_USER" > /shared/attempted_login

if [$USER_ID -eq 0 && $SFTPGO_LOGIND_PROTOCOL == "OIDC"]; then
    echo '{"status": 1, "username": "$USER_NAME"}'
else
    echo ""
fi