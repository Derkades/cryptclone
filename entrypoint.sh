#!/bin/bash

mkdir -p /root/.config/rclone
touch /root/.config/rclone/rclone.conf

rclone config create webdav \
    "webdav" \
    "url" "$REMOTE_URL" \
    "vendor" "other" \
    "user" "$REMOTE_USER" \
    "pass" "$REMOTE_PASS" \
    > /dev/null

rclone config create crypt \
    "crypt" \
    "remote" "webdav:cryptclone" \
    "filename_encryption" "standard" \
    "directory_name_encryption" "true" \
    "password" "$ENCRYPT_PASS" \
    > /dev/null

TAGS=""

if [ "$PROGRESS" == "true" ]
then
    TAGS="--progress"
fi

TAGS="$TAGS --bwlimit $BWLIMIT"
TAGS="$TAGS --transfers $TRANSFERS"

echo "Starting backup at `date`"
echo "  remote: $REMOTE_URL"
echo "  options: $TAGS"

echo ""
echo "----------------------------------"
echo ""

if [ "$1" == "sync" ]
then
    rclone sync $TAGS /data crypt:
elif [ "$1" == "restore" ]
then
    rclone copy $TAGS crypt: /data
else
    echo "Unsupported command '$1'"
    exit 1
fi

echo ""
echo "----------------------------------"
echo ""

echo "Backup finished at `date`"
