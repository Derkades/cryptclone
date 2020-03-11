#!/bin/sh

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

if [ "$PROGRESS" == "true" ]
then
    PROGRESS="--progress"
else
    PROGRESS=""
fi

if [ "$1" == "sync" ]
then
    CMD="sync"
    SRC="/data"
    DST="crypt:"
elif [ "$1" == "restore" ]
then
    if [ "$CHECK_RESTORE_DEST_EMPTY" == "true" ] && [ "`ls -1A /data`" != "" ]
    then
        echo "Restore directory not empty, aborting."
        echo "If you know what you are doing, set environment variable CHECK_RESTORE_DEST_EMPTY to 'false' to override."
        exit 1
    fi

    CMD="copy"
    SRC="crypt:"
    DST="/data"
else
    echo "Unsupported command '$1'"
    exit 1
fi

echo "Starting backup at `date`"
echo "  remote: $REMOTE_URL"

echo ""

rclone "$CMD" $PROGRESS --bwlimit "$BWLIMIT" --transfers "$TRANSFERS" "$SRC" "$DST"

echo ""

echo "Backup finished at `date`"
