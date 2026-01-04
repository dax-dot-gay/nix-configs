/run/current-system/sw/bin/rm -rf /shared/systems/services/access/login-attempt.json
echo "$SFTPGO_LOGIND_USER" > /shared/systems/services/access/login-attempt.json
USER_ID="$(/run/current-system/sw/bin/jq .id /shared/systems/services/access/login-attempt.json)"
USER_NAME="$(/run/current-system/sw/bin/jq .username /shared/systems/services/access/login-attempt.json)"

if [ $USER_ID -eq 0 ]; then
    if [ $SFTPGO_LOGIND_PROTOCOL = "OIDC" ]; then
        JQ_OUT=$(/run/current-system/sw/bin/printf '{
            "status": 1,
            "username": "%s",
            "has_password": false,
            "permissions": {
                "/": ["*"]
            }
        }' "${USER_NAME}")

        echo -e "${JQ_OUT}"
    else
        echo ""
    fi
else
    echo ""
fi

/run/current-system/sw/bin/rm -rf /shared/systems/services/access/login-attempt.json