FROM archlinux:latest

EXPOSE 22

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; pacman -Syu --noconfirm \
      sudo cronie tzdata \
      nushell git \
      openssh rsync dropbear s3fs \
      tcpdump socat websocat \
      ripgrep dust \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  #; echo "Defaults env_keep += \"PATH\"" >> /etc/sudoers \
  \
  ; rm -rf /var/cache/pacman/pkg/* \
  #; rm -rf /var/lib/pacman/* \
  ;

ENV DEBUGE=
ENV PREBOOT=
ENV POSTBOOT=
ENV CRONFILE=
COPY entrypoint /entrypoint

ENV git_pull=
#ENV ed25519_xxx=

ENTRYPOINT [ "/entrypoint/init.sh" ]
