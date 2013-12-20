FROM inthecloud247/kdocker-ubuntu
MAINTAINER inthecloud247 "inthecloud247@gmail.com"

ENV LAST_UPDATED 2013-12-20

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

# put custom commands here
RUN \
  `# Install hekad (using cache if possible)`; \
  cd /setupfiles/cache; \
  wget -p -c --no-check-certificate https://github.com/mozilla-services/heka/releases/download/v0.4.2/heka_0.4.2_amd64.deb; \
  dpkg -i ./github.com/mozilla-services/heka/releases/download/v0.4.2/heka_0.4.2_amd64.deb; \
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
  rm -vrf /setupfiles; \
  \
  `# Add LOGSERVER ip address to hekad config`; \
  LOGSERVER_IP=$(/sbin/ip route | awk '/default/ { print $3; }'); \
  sed -i "s/{{LOGSERVER_IP}}/$LOGSERVER_IP/g" /etc/hekad/aggregator_output.toml;

# expose ports, add volumes and execute the CMD script
EXPOSE 22
EXPOSE 5565
VOLUME [ "/data" ]
CMD ["/usr/bin/supervisord", "--nodaemon"]