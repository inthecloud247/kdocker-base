FROM inthecloud247/kdocker-ubuntu
MAINTAINER inthecloud247 "inthecloud247@gmail.com"

ENV LAST_UPDATED 2013-12-26

# Dev Packages (very large.)
RUN \
 apt-get -y install \
   python-software-properties \
   build-essential \
   make \
   automake \
   uuid-dev \
   libtool   

RUN \
  apt-get -y install \
    openssh-server \
    ssh \
    git \
    supervisor \
    cron;

## NO CACHING past this point ##

# copy required conf files and folders
ADD setupfiles/ /setupfiles/

# standard directory setup
RUN \
  `# Create cache directory`; \
  DIR_CACHE="/setupfiles/cache/"; \
  mkdir -vp $DIR_CACHE; \

# put custom commands here
RUN \
  `# Install hekad`; \
  DL_PROTO="https://"; \
  DL_FILE="github.com/mozilla-services/heka/releases/download/v0.4.2/heka_0.4.2_amd64.deb"; \
  cd $DIR_CACHE; \
  wget -p -c --no-check-certificate $DL_PROTO$DL_FILE; \
  dpkg -i $DIR_CACHE$DL_FILE; \
  \
  `# fix ssh`; \
  mkdir -v /var/run/sshd; \
  \
  `# Setup ubuntu user and set default passwords`; \
  useradd -d /home/ubuntu -m ubuntu -s /bin/bash -c "ubuntu user"; \
  adduser ubuntu sudo; \
  echo 'ubuntu:ubuntu' | chpasswd; \
  echo 'root:root' | chpasswd; \
  \
  `# Setup supervisord config files and log directories`; \
  for p in hekad crond sshd; do mkdir -v /var/log/supervisor/$p; done; \
  cp -vr /setupfiles/confs/etc /; \
  \
  `# Add LOGSERVER ip address to hekad config`; \
  LOGSERVER_IP=$(/sbin/ip route | awk '/default/ { print $3; }'); \
  sed -i "s/{{LOGSERVER_IP}}/$LOGSERVER_IP/g" /etc/hekad/aggregator_output.toml;

# cleanup
RUN \
  `# CLEANUP`; \
  rm -vrf /setupfiles;



# expose ports, add volumes and execute the CMD script
EXPOSE 22
EXPOSE 5565
VOLUME [ "/data" ]
CMD ["/usr/bin/supervisord", "--nodaemon"]