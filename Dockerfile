FROM ubuntu:noble
LABEL maintainer="juan.baptiste@gmail.com"

ENV DISPLAY=:100
ENV WEB_VIEW_PORT=10000
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/user
ENV XDG_RUNTIME_DIR=/home/user/.runtime
ENV XDG_CONFIG_HOME=/home/user/.config

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    curl -fsSL https://xpra.org/xpra.asc -o /usr/share/keyrings/xpra.asc && \
    chmod 644 /usr/share/keyrings/xpra.asc && \
    printf '%s\n' \
        'Types: deb' \
        'URIs: https://xpra.org' \
        'Suites: noble' \
        'Components: main' \
        'Signed-By: /usr/share/keyrings/xpra.asc' \
        'Architectures: amd64 arm64' \
        > /etc/apt/sources.list.d/xpra.sources && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        dbus-x11 \
        desktop-file-utils \
        gosu \
        menu \
        openbox \
        xdg-utils \
        xpra \
        xvfb && \
    xpra --version && \
    rm -f /etc/xpra/ssl/key.pem /etc/xpra/ssl/ssl-cert.pem /etc/xpra/ssl/cert.pem && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -ms /bin/bash -G xpra user
COPY entrypoint.sh /
EXPOSE 10000
