ARG BASEIMAGE=ghcr.io/fj0r/so:rust
FROM ${BASEIMAGE}

ENV PATH=/home/${MASTER}/.moon/bin:$PATH
RUN set -eux \
  ; curl --retry 3 -fsSL https://cli.moonbitlang.com/install/unix.sh \
    | sudo -u ${MASTER} bash \
  ;
