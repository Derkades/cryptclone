# Cryptclone

Are you looking for an easy way to store an encrypted copy of your important data on another server, for example your friend's NAS? If so, this docker image is for you.

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
      - '/opt/ImportantProgram/data:/data/important-program:ro'
      - '/opt/Application:/data/application:ro'
    environment:
      REMOTE_URL: http://123.45.67.89:80
      REMOTE_USER: user
      REMOTE_PASS: password
      ENCRYPT_PASS: verysecretpassword
```

* Add as many volumes as you want to the volumes section. I recommend adding the `:ro` (read only) suffix, so you can be sure that the random docker container you are using doesn't destroy your files.
* Make sure to store your encryption password carefully! If you lose this, you will lose your backups as well.
* To start a backup, run `docker-compose up -d cryptclone`. Use `up` instead of `run` so there can only be one instance of the container running at once.

### Restore

```yaml
version: '2'
services:
  restore:
    image: derkades/cryptclone
    command: restore
    volumes:
      - '/mnt/restore:/data/documents'
    environment:
      REMOTE_URL: http://123.45.67.89:80
      REMOTE_USER: user
      REMOTE_PASS: password
      ENCRYPT_PASS: verysecretpassword
```

```sh
docker-compose run --rm restore
```

* Restore `/data` or specify a subdirectory to only restore a subset of data.

## Monitoring

### Non-interactive mode

This mode is used by default. In this mode, the container will print a line to the log with progress every minute:

```text
2020/05/23 17:51:56 NOTICE: 354.781M / 5.068 GBytes, 7%, 470.319 kBytes/s, ETA 2h55m27s (xfr#270/345)
2020/05/23 17:52:56 NOTICE: 380.398M / 5.068 GBytes, 7%, 467.932 kBytes/s, ETA 2h55m24s (xfr#295/347)
2020/05/23 17:53:56 NOTICE: 409.704M / 5.090 GBytes, 8%, 470.099 kBytes/s, ETA 2h54m21s (xfr#320/352)
```

Follow the logs using `docker-compose logs -f cryptclone`

### Interactive mode

If you want more detailed live progress information, you can choose to use interactive mode. You will need to make some changes to your compose file:

* Add `tty: 'true'` to run the container in interactive mode
* Set environment variable `INTERACTIVE_PROGRESS=true`
* Set a container name using `container_name: 'something'`

You can now monitor progress using `docker attach <container name>` while the container is running. It will look something like this:

```text
Transferred:       39.739M / 44.633 MBytes, 89%, 299.512 kBytes/s, ETA 16s
Checks:             21341 / 21341, 100%
Transferred:           32 / 34, 94%
Elapsed time:      2m15.8s
Transferring:
 *                   grafana/grafana.db:  87% /2.582M, 471.446 kBytes/s, -
 *              pictures/cool-photo.jpg:  15% /2.312M, 274.348 kBytes/s, -
 ```

## Cron

Create a new file in your cron directory (probably in `/etc/cron.d`). For daily at 2AM:

```cron
0 2 * * * root docker rm cryptclone; docker-compose -f /path/to/docker-compose.yaml up cryptclone
```

This uses `rm; up` rather than `run --rm` so there can never be more than one instance of the container. If a backup job is still running when the cron job runs the existing job will continue and no new job will be started.

Make sure the cron file has a newline at the end! Feel free to customize the time, when doing so, an [online schedule preview tool](https://crontab.guru) may be useful.

## Bandwidth limit

Set bandwidth limit. For scheduling, set a whitespace separated list of times with speeds in kilobytes/s. (note that internet speed is usually measured in bits instead of bytes per second, 8 times larger!)

```yaml
BWLIMIT: '512' # Limit to 4 Mb/s
BWLIMIT: '2M' # Limit to 16 Mb/s
BWLIMIT: '06:00,512 01:00,1M' # 4 Mb/s during the day, 8Mb/s after 1AM
BWLIMIT: 'Mon-00:00,512 Fri-23:59,off Sat-09:00,1M Sun-20:00,off"
```

For more info, see the [rclone documentation](https://rclone.org/docs/#bwlimit-bandwidth-spec).

## More options

Use `RCLONE_OPTIONS` to pass command line options to rclone:

```yaml
environment:
  RCLONE_OPTIONS: '--transfers 2 --order-by size,asc --local-no-check-updated --checkers 10 --exclude some/directory/**'
```

## Troubleshooting

* If you are getting `401 Unauthorized` errors and you are sure the username/password is correct, set a shorter password. I haven't looked into this, but apparently either nginx, htpasswd or rclone seems to have issues with long passwords.
* If you are getting errors like `corrupted on transfer: sizes differ` or `connection broken: http: ContentLength=number with Body length othernumber`  it's because rclone is uploading a file while another program is modifying it. In most cases this is a log file that you don't really need to back up anyway, so use `--exclude` to exclude it. (e.g. `--exclude app/log.txt` or `--exclude app/logs/**`)
