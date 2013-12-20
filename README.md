kdocker-base
============

### Introduction

A base linux image based on ubuntu:12.04.3-LTS 
Supervisord, Hekad, Cron, sshd and standard build utils have been pre-installed in this image. It will serve as base image for all the kdocker series of Docker images.

### Usage

##### From Docker Public Repository

  > docker pull inthecloud/kdocker-base

##### Using Source

  > git clone git@github.com:ydavid365/kdocker-base.git
  > cd kdocker-base
  > docker build -t {{ user }}/{{ image-name }} .

### Login Details

- root / root
- ubuntu / ubuntu

### Installed Packages

curl python-software-properties nano supervisor git uuid-dev libtool automake pkg-config unzip make build-essential rsync openssh-server ssh git supervisor cron heka

### Configured Services & Ports

- supervisord / -
- hekad / 5565
- crond / -
- sshd / 22

### Set local firewall:

- sudo ufw allow 5565/tcp