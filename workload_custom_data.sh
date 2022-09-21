#!/bin/bash
until ping -c3 -W1 1.1.1.1; do echo "waiting for internet connectivity ..." && sleep 5; done
snap install docker               
systemctl enable snap.docker.dockerd
systemctl start snap.docker.dockerd
sleep 30
docker run -d --name=tailscaled -v /var/lib:/var/lib -v /dev/net/tun:/dev/net/tun --network=host --privileged tailscale/tailscale tailscaled --state=/tmp/tailscaled.state
docker run -d --net=host --restart=always \-e F5DEMO_APP=text \-e F5DEMO_NODENAME='Workload site Environment' \-e F5DEMO_COLOR=ffd734 \
-e F5DEMO_NODENAME_SSL='Workload Environment (Backend App)' \
-e F5DEMO_COLOR_SSL=a0bf37 \
-e F5DEMO_BRAND=volterra \
public.ecr.aws/y9n2y5q5/f5-demo-httpd:openshift
docker exec tailscaled tailscale up --authkey=${tailscale_key} --hostname=${tailscale_hostname}

cat >> /etc/hosts <<EOF
10.64.15.254  workload.site1
10.64.15.254  workload.site2
10.64.15.254  workload.site3
EOF
cat > /etc/systemd/system/tester.service <<EOF
[Unit]
Description=iperf3 client
After=syslog.target network.target auditd.service

[Service]
ExecStart=/root/tester.sh

[Install]
wantedBy=multi-user.target
EOF
cat > /root/tester.sh <<EOF
#!/bin/bash
while true; do
  for site in workload.site1 workload.site2 workload.site3; do
    curl -m 3 $$site/txt
  done
  sleep 5
done
EOF
chmod +x /root/tester.sh
systemctl enable tester
systemctl start tester
