FROM derkades/rclone-alpine

ADD entrypoint.sh /entrypoint.sh

# https://rclone.org/docs/#bwlimit-bandwidth-spec
ENV BWLIMIT="0"
ENV INTERACTIVE_PROGRESS="false"
ENV CHECK_RESTORE_DEST_EMPTY="true"
ENV REMOTE_FOLDER="cryptclone"
ENV RCLONE_OPTIONS=""
ENV RESTORE_DIR=""

VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
