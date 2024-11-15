FROM ghcr.io/nssac/mambascif AS mamba_scif_install
FROM ghcr.io/iqbal-lab-org/minos

ARG VERSION
ENV VERSION=${VERSION:-0.0.0}

RUN apt-get update && \
    apt-get install --assume-yes \
    curl \
    git \
    jq \
    tree && \
    apt-get clean --assume-yes

# Don't fail on first-time host key check for any %appinstall
# needing to clone code from Github.
RUN echo "StrictHostKeyChecking accept-new" >> /etc/ssh/ssh_config

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
ENV PATH="${PATH}:${MAMBA_ROOT_PREFIX}/bin"
COPY --from=mamba_scif_install $MAMBA_EXE $MAMBA_EXE
COPY --from=mamba_scif_install $MAMBA_ROOT_PREFIX $MAMBA_ROOT_PREFIX

RUN --mount=type=secret,id=gh_token \
  ls -la /run/secrets

# RUN mkdir -p /run/secrets

RUN --mount=type=secret,id=gh_token --mount=type=bind,target=/docker_context\
    curl https://$(cat /run/secrets/gh_token)@raw.githubusercontent.com/NSSAC/SciducTainer/refs/heads/main/sciduct.scif > /tmp/sciduct.scif && \
    cat /tmp/sciduct.scif

RUN --mount=type=secret,id=gh_token --mount=type=bind,target=/docker_context scif --help
RUN --mount=type=secret,id=gh_token --mount=type=bind,target=/docker_context\
   scif install /tmp/sciduct.scif

RUN --mount=type=secret,id=gh_token --mount=type=bind,target=/docker_context\
    scif install /docker_context/minos.scif

RUN --mount=type=secret,id=gh_token --mount=type=bind,target=/docker_context\
    scif install /docker_context/varifier.scif

RUN --mount=type=secret,id=gh_token --mount=type=bind,target=/docker_context\
    scif install /docker_context/simutator.scif    

RUN rm -rf /run/secrets || true

ENTRYPOINT ["scif"]

CMD ["shell"]