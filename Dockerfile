ARG RCLONE_TAG=latest

FROM derkades/rclone:${RCLONE_TAG}

ADD entrypoint.sh /entrypoint.sh

VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
