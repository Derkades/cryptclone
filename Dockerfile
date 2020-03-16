ARG RCLONE_TAG=latest

FROM derkades/rclone:${RCLONE_TAG}

ADD entrypoint.sh /entrypoint.sh

# https://rclone.org/docs/#bwlimit-bandwidth-spec
ENV BWLIMIT="0"
# https://rclone.org/docs/#transfers-n
ENV TRANSFERS="4"
# Disable if redirecting log to a file
ENV PROGRESS="false"

ENV CHECK_RESTORE_DEST_EMPTY="true"

ENV REMOTE_FOLDER="cryptclone"

VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
