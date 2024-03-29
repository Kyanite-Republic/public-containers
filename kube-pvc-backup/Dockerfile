FROM debian:stable-slim

RUN apt-get update && apt-get full-upgrade -y && apt install -y \
    tar ssh sshpass mariadb-client

COPY /kube-pvc-backup/backup.sh .

CMD ["bash", "./backup.sh"]