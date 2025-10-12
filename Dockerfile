FROM ubuntu:jammy
LABEL maintainer="juan.baptiste@gmail.com"
ENV DISPLAY=:100
ENV WEB_VIEW_PORT 10000
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common wget gnupg && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y xpra xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -ms /bin/bash -G xpra user
COPY entrypoint.sh /
EXPOSE 10000
