ARG BASEIMAGE=ghcr.io/fj0r/so:latest
FROM ${BASEIMAGE}

ARG PIP_FLAGS="--break-system-packages"
ARG PIP_INDEX_PYTORCH="--index-url https://download.pytorch.org/whl/cpu"

ENV HOME=/home/${MASTER}
ENV PATH=${HOME}/.local/bin:$PATH
ENV LANG=zh_CN.UTF-8

WORKDIR ${HOME}

ENV PORT=8080
EXPOSE $PORT

ENV HOST=0.0.0.0

### CONDA
ENV JUPYTER_ROOT=
ENV JUPYTER_PASSWORD=
ENV CONDA_HOME=/opt/conda
ENV PATH=${CONDA_HOME}/bin:$PATH

RUN set -ex \
  ; pip install --no-cache-dir ${PIP_FLAGS} \
      psycopg[binary] lancedb \
      polars[all] numpy scikit-learn \
      httpx aiofile aiostream fastapi uvicorn \
      debugpy pytest pydantic pydantic-graph PyParsing \
      typer pydantic-settings pyyaml \
      boltons decorator \
      pydantic-ai deltalake \
      marimo[recommended,lsp,sql] altair \
  ;

RUN set -ex \
  ; pip install --no-cache-dir ${PIP_FLAGS} ${PIP_INDEX_PYTORCH} \
      torch torchvision torchaudio \
  ;

COPY entrypoint/marimo.sh /entrypoint/
CMD ["srv"]
USER ${MASTER}
