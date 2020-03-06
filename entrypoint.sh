#!/bin/bash

mkdir -p /root/.config/rclone
touch /root/.config/rclone/rclone.conf

rclone config create webdav \
    "webdav" \
    "url" "$REMOTE_URL" \
    "vendor" "other" \
    "user" "$REMOTE_USER" \
    "pass" "$REMOTE_PASS"

rclone config create crypt \
    "crypt" \
    "remote" "webdav:cryptclone" \
    "filename_encryption" "standard" \
    "directory_name_encryption" "true" \
    "password" "$ENCRYPT_PASS"

if [ "$1" == "sync" ]
then
    rclone sync --progress --bwlimit "$BWLIMIT" --transfers "$TRANSFERS" /data crypt:
elif [ "$1" == "restore" ]
then
    rclone copy --progress --bwlimit "$BWLIMIT" --transfers "$TRANSFERS" crypt: /data
else
    echo "Unsupported command '$1'"
    exit 1
fi
