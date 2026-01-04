#/bin/bash

USER_ID="$(jq .id $SFTPGO_LOGIND_USER)"
USER_NAME="$(jq .username $SFTPGO_LOGIND_USER)"

if [[$USER_ID -eq 0 && $SFTPGO_LOGIND_PROTOCOL == "OIDC"]]; then
    echo '{"status": 1, "username": "$USER_NAME"}'
else
    echo ""
fi