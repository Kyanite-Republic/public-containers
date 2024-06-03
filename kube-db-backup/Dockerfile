FROM debian:stable-slim

RUN apt-get update && apt-get full-upgrade -y && apt install -y \
    tar mariadb-client

COPY /kube-db-backup/backup.sh .

CMD ["bash", "./backup.sh"]