#!/bin/bash
set -euo pipefail

#Read env variables set by derived containers.
if [ -f .envrc ]; then
  . .envrc
fi

DEBUG="${DEBUG:-no}"
CMD="${CMD:-}"
ENABLE_WEB_VIEW="${ENABLE_WEB_VIEW:-no}"
WEB_VIEW_PORT="${WEB_VIEW_PORT:-10000}"
START_WINDOW_MANAGER="${START_WINDOW_MANAGER:-yes}"
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/home/user/.runtime}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/home/user/.config}"
export XDG_RUNTIME_DIR
export XDG_CONFIG_HOME

if [ "${DEBUG}" = "yes" ]; then
  env
  set -x
fi

if [ -z "${CMD}" ]; then
  echo "ERROR: No command specified." && exit 1
fi

mkdir -p "${XDG_RUNTIME_DIR}" "${XDG_CONFIG_HOME}/menus" /home/user/.xpra
chmod 700 "${XDG_RUNTIME_DIR}" /home/user/.xpra

cat > "${XDG_CONFIG_HOME}/menus/applications.menu" <<'EOF'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
 "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
  <Name>Applications</Name>
  <DefaultAppDirs/>
  <DefaultDirectoryDirs/>
  <Include>
    <All/>
  </Include>
</Menu>
EOF

cp "${XDG_CONFIG_HOME}/menus/applications.menu" "${XDG_CONFIG_HOME}/menus/debian-menu.menu"
cp "${XDG_CONFIG_HOME}/menus/applications.menu" "${XDG_CONFIG_HOME}/menus/kde-debian-menu.menu"
update-desktop-database /usr/share/applications >/dev/null 2>&1 || true

#Use Xpra to enable access through a web browser
if [ "${ENABLE_WEB_VIEW}" = "yes" ]; then

  XPRA_ARGS=(
    start
    "--bind-tcp=0.0.0.0:${WEB_VIEW_PORT}"
    --html=on
    --daemon=no
    --pulseaudio=no
    --notifications=no
    --bell=no
    --mdns=no
    --dbus-launch=no
  )

  if [ "${START_WINDOW_MANAGER}" != "no" ]; then
    XPRA_ARGS+=(--start-child=/usr/bin/openbox)
  fi

  XPRA_ARGS+=("--start=${CMD}")

  #Check if credentials have been provided
  if [ -n "${XPRA_USER:-}" ] && [ -n "${XPRA_PASSWORD:-}" ]; then
    python3 /usr/lib/python3/dist-packages/xpra/server/auth/sqlite_auth.py /home/user/auth.sdb create
    python3 /usr/lib/python3/dist-packages/xpra/server/auth/sqlite_auth.py /home/user/auth.sdb add "${XPRA_USER}" "${XPRA_PASSWORD}"
    XPRA_ARGS+=(
      --auth=sqlite:filename=/home/user/auth.sdb
      --ws-auth=sqlite:filename=/home/user/auth.sdb
      --tcp-auth=sqlite:filename=/home/user/auth.sdb
    )
  fi

  exec xvfb-run -a --server-args="-screen 0 1600x1200x24" xpra "${XPRA_ARGS[@]}"
else
  exec ${CMD}
fi
