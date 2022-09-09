FROM ubuntu:bionic
ENV SAVA_VERSION=1.5.0-rc
ENV DEBIAN_FRONTEND noninteractive
ENV TZ "America/New_York"
ENV CUPSADMIN admin
ENV CUPSPASSWORD password

RUN apt-get update && \
    apt-get -y install cups cups-bsd poppler-utils qpdf imagemagick wget gnupg \
    software-properties-common avahi-daemon avahi-discover libnss-mdns \
    binutils wget curl supervisor openssh-server debianutils perl gzip 
    

RUN apt-get install cpio default-jdk -y

RUN useradd -r savapage && \
    mkdir -p /opt/savapage && \
    usermod -s /bin/bash savapage && \
    usermod -d /opt/savapage savapage && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /run/sshd 

COPY config/cupsd.conf /etc/cups/cupsd.conf

COPY config/cups-browsed.conf /etc/cups/cups-browsed.conf

COPY config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY config/papersize /etc/papersize

COPY config/wireguard-route /etc/network/if-up.d/wireguard-route

RUN chmod 751 /etc/network/if-up.d/wireguard-route

RUN mkdir -p /opt/savapage && cd /opt/savapage && \
    wget https://www.savapage.org/download/snapshots/savapage-setup-${SAVA_VERSION}-linux-x64.bin -O savapage-setup-linux.bin && \
    chown savapage:savapage /opt/savapage && \
    chmod +x savapage-setup-linux.bin

RUN su savapage sh -c "/opt/savapage/savapage-setup-linux.bin -n" && \
    /opt/savapage/MUST-RUN-AS-ROOT


ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]


#CMD ["/usr/bin/supervisord"]

# CMD ["/bin/bash"]
