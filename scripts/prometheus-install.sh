#!/usr/bin/env bash

yum -y update

PROMETHEUS_VERSION=2.4.3
NODE_EXPORTER_VERSION=0.16.0
GRAFANA_VERSION=5.2.4-1

# Create prometheus user
useradd prometheus -c "Prometheus" --no-create-home --system --shell /sbin/nologin

install_grafana() {
	curl -sSl https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-${GRAFANA_VERSION}.x86_64.rpm -o /tmp/grafana.rpm
	yum -y localinstall /tmp/grafana.rpm
	rm -f /tmp/grafana.rpm
	systemctl enable grafana-server
	systemctl restart grafana-server
}

install_prometheus() {
	curl -sSL https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -o /tmp/prometheus.tar.gz
	mkdir -p /opt/prometheus/dist
	tar -xf /tmp/prometheus.tar.gz -C /opt/prometheus/dist
	rm -f /tmp/prometheus.tar.gz
	ln -sf /opt/prometheus/dist/prometheus-${PROMETHEUS_VERSION}.linux-amd64 /opt/prometheus/prometheus_current
	chown -R prometheus:prometheus /opt/prometheus

	# Create systemd file
	tee /etc/systemd/system/prometheus.service >/dev/null <<EOF
[Unit]
Description=Prometheus Server
After=network.target

[Service]
Type=simple
User=prometheus
Group=prometheus
WorkingDirectory=/opt/prometheus/prometheus_current
Restart=always
ExecStart=/opt/prometheus/prometheus_current/prometheus

[Install]
WantedBy=multi-user.target
EOF
	
	# Enable and start services
	systemctl daemon-reload
	systemctl enable prometheus
	systemctl restart prometheus
}

install_node_exporter() {
	# Install node-exporter
	curl -sSL https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz -o /tmp/node_exporter.tar.gz
	mkdir -p /opt/prometheus/dist
	tar -xf /tmp/node_exporter.tar.gz -C /opt/prometheus/dist
	rm -f /tmp/node_exporter.tar.gz
	ln -sf /opt/prometheus/dist/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 /opt/prometheus/node_exporter_current
	chown -R prometheus:prometheus /opt/prometheus

	# Create systemd file
	tee /etc/systemd/system/node-exporter.service >/dev/null <<EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
User=prometheus
Group=prometheus
Restart=always
ExecStart=/opt/prometheus/node_exporter_current/node_exporter \
--collector.systemd  \
--web.listen-address=0.0.0.0:9100 --log.level=info

[Install]
WantedBy=multi-user.target
EOF
	
	# Enable and start services
	systemctl daemon-reload
	systemctl enable node-exporter
	systemctl restart node-exporter
}

install_prometheus
install_grafana
install_node_exporter
