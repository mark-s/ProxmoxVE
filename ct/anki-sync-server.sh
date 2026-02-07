#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Mark Staff (mark-s)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/ankitects/anki

APP="Anki Sync Server"
var_tags="${var_tags:-education;sync}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/anki-sync-server ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  CURRENT=$(/opt/anki-sync-server/venv/bin/python -c "from importlib.metadata import version; print(version('anki'))")
  LATEST=$(curl -fsSL https://pypi.org/pypi/anki/json | jq -r '.info.version')

  if [[ "${CURRENT}" == "${LATEST}" ]]; then
    msg_ok "Already up to date (v${CURRENT})"
    exit
  fi

  msg_info "Stopping Service"
  systemctl stop anki-sync-server
  msg_ok "Stopped Service"

  msg_info "Updating to v${LATEST}"
  $STD /usr/local/bin/uv pip install --python /opt/anki-sync-server/venv/bin/python --upgrade anki
  msg_ok "Updated to v${LATEST}"

  msg_info "Starting Service"
  systemctl start anki-sync-server
  msg_ok "Started Service"
  msg_ok "Updated successfully!"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"
