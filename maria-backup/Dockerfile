FROM debian:stable-slim

RUN apt-get update && apt-get full-upgrade -y && apt install -y \
    mariadb-client ssh

COPY /maria-backup/backup.sh .
