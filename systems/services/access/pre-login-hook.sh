#!/bin/bash

rm -rf /var/lib/sftpgo/login-attempt.json
echo "$SFTPGO_LOGIND_USER" > /var/lib/sftpgo/login-attempt.json
USER_ID="$(/run/current-system/sw/bin/jq .id /var/lib/sftpgo/login-attempt.json)"
USER_NAME="$(/run/current-system/sw/bin/jq .username /var/lib/sftpgo/login-attempt.json)"

if [$USER_ID -eq 0 && $SFTPGO_LOGIND_PROTOCOL == "OIDC"]; then
    echo '{"status": 1, "username": "$USER_NAME"}'
else
    echo ""
fi

rm -rf /var/lib/sftpgo/login-attempt.json