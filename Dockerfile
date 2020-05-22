FROM derkades/rclone-alpine

ADD entrypoint.sh /entrypoint.sh

# https://rclone.org/docs/#bwlimit-bandwidth-spec
ENV BWLIMIT="0"
# Deprecated, use --transfers in RCLONE_OPTIONS
ENV TRANSFERS="4"
ENV PROGRESS="true"
ENV CHECK_RESTORE_DEST_EMPTY="true"
ENV REMOTE_FOLDER="cryptclone"
# Deprecated, use RCLONE_OPTIONS
ENV RCLONE_PARAMS=""
ENV RCLONE_OPTIONS=${RCLONE_PARAMS}

VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
