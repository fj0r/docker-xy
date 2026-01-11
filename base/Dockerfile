FROM archlinux:latest

ARG MASTER=master
ENV MASTER=${MASTER}

EXPOSE 22

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai \
    PYTHONUNBUFFERED=x

RUN set -eux \
  ; pacman -Syu --noconfirm \
      sudo cronie tzdata \
      # base-devel \
      nushell git \
      openssh rsync dropbear s3fs \
      tcpdump socat websocat \
      ripgrep dust \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i 's/# \(%.*NOPASSWD.*\)/&\n\1/' /etc/sudoers \
  \
  # ; paru_url=$(curl -sSL https://api.github.com/repos/Morganamilo/paru/releases/latest \
  #   | nu --stdin -c 'from json | get tag_name | $"https://github.com/Morganamilo/paru/releases/download/($in)/paru-($in)-x86_64.tar.zst"') \
  # ; curl $paru_url | zstd -d | tar -xf - paru -C /usr/local/bin \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; useradd -mU -G wheel,root -s /usr/bin/nu $MASTER \
  ; mkdir -p /home/${MASTER} \
  ; chown $MASTER:$MASTER -R /home/${MASTER} \
  ; XDG_CONFIG_HOME=/home/${MASTER}/.config \
  ; mkdir -p $XDG_CONFIG_HOME \
  ; chown $MASTER:$MASTER -R $XDG_CONFIG_HOME \
  \
  ; git clone --depth=3 https://github.com/fj0r/nushell.git $XDG_CONFIG_HOME/nushell \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nushell; git log -1 --date=iso; cd $opwd \
  ; chown $MASTER:$MASTER -R $XDG_CONFIG_HOME/nushell \
  ; sudo -u $MASTER nu -c "plugin add /usr/bin/nu_plugin_query" \
  ; echo '$env.NU_POWER_CONFIG.theme.color.normal = "xterm_olive"' >> /home/${MASTER}/.nu \
  ; chown $MASTER:$MASTER /home/${MASTER}/.nu \
  \
  ; pacman -S --noconfirm python python-pip \
  ; pip install --no-cache-dir --break-system-packages \
        ty \
        httpx aiofile aiostream fastapi uvicorn \
        debugpy pytest pydantic pydantic-graph PyParsing \
        typer pydantic-settings pyyaml \
        boltons decorator \
  \
  ; pacman -S --noconfirm bun \
  ; bun install --global --no-cache \
        @typespec/compiler @typespec/json-schema \
        vscode-langservers-extracted \
        yaml-language-server \
  \
  ; rm -rf /var/cache/pacman/pkg/* \
  #; rm -rf /var/lib/pacman/* \
  ;

VOLUME /home/${MASTER}
WORKDIR /home/${MASTER}

ENV DEBUGE=
ENV PREBOOT=
ENV POSTBOOT=
ENV CRONFILE=
ENV git_pull=
#ENV ed25519_xxx=

COPY entrypoint /entrypoint

ENTRYPOINT [ "/entrypoint/init.sh" ]
