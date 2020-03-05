# Cryptclone

Are you looking for an easy way to store a copy of your important data on another server, for example your friend's NAS? If so, this docker image is for you.

## Features

* Can tolerate bad internet connections, it will resume where it left off if it is interrupted
* Encrypts files client-side before uploading them to the remote. File and directory names are encrypted as well, but the original structure is kept.
* Restore everything or specific subdirectories
* Arm support for server-side (I'm working on supporting arm for client side as well). Add `:arm` after the image name.

## Installation

### Server-side

On the server side, create a new directory with a `docker-compose.yaml` file with the following content (or add it to an existing file):

```yaml
version: '2'

services:
  backup_server:
    image: derkades/webdav
    ports: ['8080:80']
    volumes: ['./data:/data']
    environment:
      USERNAME: user
      PASSWORD: password
    restart: unless-stopped
```

Change the outside port if needed, and of course the data storage location, username and password.

Run `docker-compose up -d` in the same directory to start the server. Because `restart: unless-stopped` is set, the service will automatically start at boot. Use `docker-compose rm -sf` to stop and remove the service. To check if it is working, you can visit the address in a web browser.

### Client-side

Create a new directory with a `docker-compose.yaml` file with the following content.

```yaml
version: '2'
services:
  cryptclone:
    image: derkades/cryptclone
    command: sync
    volumes:
      - '/home/user/Documents:/data/documents:ro'
      - '/home/user/Downloads:/data/downloads:ro'
      - '/opt/Application:/data/application:ro'
    environment:
      REMOTE_URL: http://123.45.67.89:80
      REMOTE_USER: user
      REMOTE_PASS: password
      ENCRYPT_PASS: verysecretpassword
```

* Add as many volumes as you want to the volumes section. I recommend adding `:ro` (read only) to the end, so you can be sure that the random docker container you just downloaded doesn't destroy your files.
* Make sure to store your encryption password carefully! If you lose this, you will lose your backups as well.
* To start a backup, run `docker-compose run --rm cryptclone`
* If you already have a docker-compose file with other services, you may be tempted to add it there. I do not recommend doing this, you may accidentally start the container when doing `docker-compose up -d` to start all your containers.

## Cron

Create a new file in your cron directory (probably in `/etc/cron.d`). Yes, on the host system, fight me. For daily at 2AM:

```cron
0 2 * * * root docker-compose -f /path/to/docker-compose.yaml run --rm cryptclone
```

Feel free to customize the time, when doing so, an [online schedule preview tool](https://crontab.guru) may be useful.

## Troubleshooting

* If you are getting `401 Unauthorized` errors and you are sure the username/password is correct, set a shorter password. I haven't looked into this, but apparently either nginx, htpasswd or rclone seems to have issues with long passwords.
