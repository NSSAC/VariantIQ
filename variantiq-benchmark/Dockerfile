# FROM ghcr.io/nssac/mambascif as mamba_scif_install
FROM ghcr.io/nssac/mambascif

ARG VERSION
ENV VERSION=${VERSION:-0.0.0}

# RUN apt-get update && \
#     apt-get install --assume-yes \
#     curl \
#     git \
#     jq \
#     tree \
#     && apt-get clean --assume-yes

# build mamba 'base' env
RUN micromamba install --name $ENV_NAME python=3.11 -y -c conda-forge && \
    micromamba run --name $ENV_NAME pip install ipython jsonschema 

RUN mkdir -p /docker_context

COPY environment.yml /docker_context/environment.yml

RUN micromamba install --name $ENV_NAME -y --file /docker_context/environment.yml

COPY ./varifier* /docker_context/
RUN scif install /docker_context/varifier.scif 

COPY ./vcfdist* /docker_context/
RUN scif install /docker_context/vcfdist.scif 

COPY src /src
COPY ./variantiq* /docker_context/
RUN scif install /docker_context/variantiq.scif 

COPY config.json /docker_context/
RUN --mount=type=secret,id=gh_token \
    curl https://$(cat /run/secrets/gh_token)@raw.githubusercontent.com/NSSAC/SciducTainer/refs/heads/main/sciduct.scif > /tmp/sciduct.scif 

RUN --mount=type=secret,id=gh_token \
   scif install /tmp/sciduct.scif

COPY benchmark_datasets/* /benchmark_datasets/

RUN rm -rf /run/secrets || true

RUN rm -rf /usr/share/dotnet /opt/ghc /usr/local/share/boost $AGENT_TOOLSDIRECTORY /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["scif","--quiet"]

CMD ["shell"]