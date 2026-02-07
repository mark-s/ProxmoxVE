#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: [YourGitHubUsername]
# License: MIT | https://github.com/mark-s/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/ankitects/anki

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

PYTHON_VERSION="3.12" setup_uv

msg_info "Installing Anki Sync Server"
mkdir -p /opt/anki-sync-server/data
$STD /usr/local/bin/uv venv /opt/anki-sync-server/venv
$STD /usr/local/bin/uv pip install --python /opt/anki-sync-server/venv/bin/python anki
msg_ok "Installed Anki Sync Server"

msg_info "Configuring Anki Sync Server"
cat <<EOF >/opt/anki-sync-server/.env
SYNC_HOST=0.0.0.0
SYNC_PORT=8080
SYNC_BASE=/opt/anki-sync-server/data
SYNC_USER1=anki:anki
MAX_SYNC_PAYLOAD_MEGS=100
EOF
msg_ok "Configured Anki Sync Server"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/anki-sync-server.service
[Unit]
Description=Anki Sync Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/anki-sync-server
EnvironmentFile=/opt/anki-sync-server/.env
ExecStart=/opt/anki-sync-server/venv/bin/python -m anki.syncserver
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now anki-sync-server
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
