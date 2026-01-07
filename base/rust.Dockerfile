ARG BASEIMAGE=ghcr.io/fj0r/xy:latest
FROM ${BASEIMAGE}

ARG RUST_CHANNEL=stable

ENV RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    RUSTC_WRAPPER=/usr/bin/sccache

ENV PATH=${CARGO_HOME}/bin:$PATH

RUN set -eux \
  ; pacman -S --noconfirm \
      rustup gcc sccache \
  ; rustup default ${RUST_CHANNEL} \
  ; rustup toolchain install \
  ; rustup component add rust-src clippy rustfmt \
  ; rustup component add rust-analyzer \
  ; rustup target add x86_64-unknown-linux-musl \
  ; rustup target add wasm32-wasip1 wasm32-wasip2 wasm32-unknown-unknown \
  ; curl -fsSL https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-musl.tgz \
    | tar zxf - -C /usr/local/bin/ \
    ; chmod +x /usr/local/bin/cargo-binstall \
  ; cargo binstall -y \
      bacon \
      cargo-pgo cargo-profiler cargo-bloat \
      cargo-expand cargo-eval cargo-tree \
      cargo-feature cargo-edit cargo-rail \
      rust-script trunk cargo-wasi \
      wasm-tools wit-deps-cli wit-bindgen-cli \
      #dioxus-cli \
      #cargo-leptos \
  ; NCF=cargo-fetch \
  ; cargo new ${NCF} \
  ; cd ${NCF} \
  ; for p in \
      clap figment tempdir \
      snafu anyhow thiserror \
      proc-macro2 syn quote macro_rules_attribute \
      linkme regex chrono moka bumpalo \
      bon indoc itertools derive_more \
      refined_type dashmap indexmap maplit arc-swap bitflags num \
      url reqwest scraper markdown \
      serde serde_derive serde_with serde_json_path \
      serde_json postcard serde_cbor schemars toml serde_yaml \
      tracing tracing-subscriber tracing-serde \
      rayon polars nalgebra linfa burn \
      crossbeam parking_lot specs \
      nom minijinja wasmtime wasmi koto \
      notify listenfd libc mimalloc \
      tokio tokio-util tokio-tungstenite smol async-compat \
      futures futures-util async-stream async-trait \
      async-fs async-graphql sqlx \
      warp async-graphql-warp \
      axum async-graphql-axum \
      # wasm-pack wee_alloc leptos \
      wasm-bindgen wasm-bindgen-futures wasm-logger \
      #dioxus dioxus-web \
      sycamore gloo-net \
      ; do echo "${p} = \"*\"" >> Cargo.toml ; done \
  ; cargo fetch \
  ; cd .. \
  ; chown ${MASTER}:${MASTER} -R ${NCF} \
  ; rm -rf ${CARGO_HOME}/registry/src/* \
  ; chown ${MASTER}:${MASTER} -R ${CARGO_HOME} \
  \
  ; rm -rf /var/cache/pacman/pkg/* \
  ;
