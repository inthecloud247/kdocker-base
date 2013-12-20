FROM inthecloud247/kdocker-ubuntu
MAINTAINER inthecloud247 "inthecloud247@gmail.com"

ENV LAST_UPDATED 2013-12-18

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
    supervisor; \
    cd /data/setupfiles/cache; \
    wget -p -c --no-check-certificate https://github.com/mozilla-services/heka/releases/download/v0.4.2/heka_0.4.2_amd64.deb; \
    dpkg -i ./github.com/mozilla-services/heka/releases/download/v0.4.2/heka_0.4.2_amd64.deb;

VOLUME [ "/var/log/supervisor"]
VOLUME [ "/data" ]

## NO CACHING past this point ##

# copy required conf files and folders
ADD setupfiles/ /data/setupfiles/

# custom commands
RUN \
  mkdir /var/run/sshd; \
  useradd -d /home/ubuntu -m ubuntu -s /bin/bash -c "ubuntu user"; \
  adduser ubuntu sudo; \
  echo 'ubuntu:ubuntu' | chpasswd; \
  echo 'root:root' | chpasswd; \
  cp -vr /data/setupfiles/confs/etc / ; \
  mkdir /var/log/supervisor/{hekad,crond,sshd} ; \
  rm -rf /data/setupfiles;

# Add correct address to hekad config
RUN \
LOGSERVER_IP=$(/sbin/ip route | awk '/default/ { print $3; }')
sed -i "s/{{LOGSERVER_IP}}/$LOGSERVER_IP/g" /etc/hekad/aggregator_output.toml


# expose ports and execute the run script
EXPOSE 22
EXPOSE 5565

CMD ["/usr/bin/supervisord", "--nodaemon"]