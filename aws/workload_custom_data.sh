#!/bin/bash
until ping -c3 -W1 1.1.1.1; do echo "waiting for internet connectivity ..." && sleep 5; done
snap install docker               
systemctl enable snap.docker.dockerd
systemctl start snap.docker.dockerd
sleep 30
docker run -d --net=host --restart=always \-e F5DEMO_APP=text \-e F5DEMO_NODENAME='Azure Environment' \-e F5DEMO_COLOR=ffd734 \
-e F5DEMO_NODENAME_SSL='Azure Environment (Backend App)' \
-e F5DEMO_COLOR_SSL=a0bf37 \
-e F5DEMO_BRAND=volterra \
public.ecr.aws/y9n2y5q5/f5-demo-httpd:openshift
