FROM quay.io/devfile/universal-developer-image:ubi8-6eb0041

# Switching to root user (setting UID to 0) because next
# commands require root privileges. Universal Developer
# Image default user has UID set to 10001.
USER 0

RUN dnf -y update && dnf -y install \
    gcc gcc-c++ make ncurses-devel patch rsync tar unzip bzip2 wget which diffutils python2 python3 perl &&\
    dnf -y clean all --enablerepo='*'

RUN npm install -g http-server

# Switch back to default user
USER 10001
