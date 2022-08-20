#!/bin/bash
until ping -c3 -W1 1.1.1.1; do echo "waiting for internet connectivity ..." && sleep 5; done
snap install docker               
systemctl enable snap.docker.dockerd
systemctl start snap.docker.dockerd
sleep 30
docker run -d --name=tailscaled -v /var/lib:/var/lib -v /dev/net/tun:/dev/net/tun --network=host --privileged tailscale/tailscale tailscaled --state=/tmp/tailscaled.state
docker run -d --net=host --restart=always \-e F5DEMO_APP=text \-e F5DEMO_NODENAME='Azure Environment' \-e F5DEMO_COLOR=ffd734 \
-e F5DEMO_NODENAME_SSL='Azure Environment (Backend App)' \
-e F5DEMO_COLOR_SSL=a0bf37 \
-e F5DEMO_BRAND=volterra \
public.ecr.aws/y9n2y5q5/f5-demo-httpd:openshift
docker exec tailscaled tailscale up --authkey=${tailscale_key} --hostname=${tailscale_hostname}

cat >> /etc/hosts <<EOF
10.64.15.254  workload.site1
10.64.15.254  workload.site2
10.64.15.254  workload.site3
EOF

if ! test -z "${grafana_agent_stack_id}"; then 
  echo Installing Grafana Agent ...
  ARCH=amd64 \
    GCLOUD_STACK_ID=${grafana_agent_stack_id} \
    GCLOUD_API_KEY=${grafana_api_key} \
    GCLOUD_API_URL=${grafana_api_url} \
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/grafana/agent/release/production/grafanacloud-install.sh)"
  wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.22.0/blackbox_exporter-0.22.0.linux-amd64.tar.gz 
  tar zxf blackbox_exporter-0.22.0.linux-amd64.tar.gz
  mv blackbox_exporter-0.22.0.linux-amd64/blackbox_exporter /usr/local/bin/blackbox_exporter

  cat > /etc/blackbox.yml <<EOF
modules:
  http_2xx:
    prober: http
    timeout: 2s
    http:
      method: GET
EOF
  useradd -rs /bin/false blackbox
  cat > /etc/systemd/system/blackbox_exporter.service <<EOF
[Unit]
Description=prometheus blackbox_exporter
After=network-online.target
Wants=network-online.target

[Service]
User=blackbox
Group=blackbox
ExecStart=/usr/local/bin/blackbox_exporter --config.file="/etc/blackbox.yml"
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
  systemctl enable blackbox_exporter  
  systemctl start blackbox_exporter
  cat > /etc/grafana-agent.yaml <<EOF
integrations:
  agent:
    enabled: true
    relabel_configs:
    - action: replace
      source_labels:
      - agent_hostname
      target_label: instance
  prometheus_remote_write:
  - basic_auth:
      username: ${grafana_agent_stack_id}
      password: ${grafana_api_key}
    url: ${grafana_api_url}
  node_exporter:
    enabled: true
metrics:
  configs:
  - name: agent
    host_filter: false
    scrape_configs:
      - job_name: ${tailscale_hostname}
        metrics_path: /probe
        params:
          module: [http_2xx]  # Look for a HTTP 200 response.
        static_configs:
          - targets:
            - workload.site1
            - workload.site2
            - workload.site3
        relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: 127.0.0.1:9115  # The blackbox exporter's real hostname:port.
    remote_write:
      - url: ${grafana_api_url}
        basic_auth:
          username: ${grafana_agent_stack_id}
          password: ${grafana_api_key}
  global:
    scrape_interval: 5s
  wal_directory: /tmp/grafana-agent-wal
EOF
  systemctl restart grafana-agent
fi

