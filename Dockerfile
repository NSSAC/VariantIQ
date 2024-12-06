FROM ghcr.io/nssac/mambascif as mamba_scif_install
FROM ghcr.io/iqbal-lab-org/clockwork

ARG VERSION
ENV VERSION=${VERSION:-0.0.0}

RUN apt-get update && \
    apt-get install --assume-yes \
    curl \
    git \
    jq \
#     # libquadmath0 \
#     tree \
#     # gcc \
#     # g++ \
#     # build-essential \
#     # pkg-config \
#     # wget \
#     # make \
#     # zlib1g-dev \
#     # libbz2-dev  \
#     # liblzma-dev \
#     # libcrypto++-dev \
    && apt-get clean --assume-yes

# Don't fail on first-time host key check for any %appinstall
# needing to clone code from Github.
RUN mkdir -p /etc/ssh
RUN echo "StrictHostKeyChecking accept-new" >> /etc/ssh/ssh_config

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
COPY --from=mamba_scif_install $MAMBA_EXE $MAMBA_EXE
COPY --from=mamba_scif_install $MAMBA_ROOT_PREFIX $MAMBA_ROOT_PREFIX
RUN ln -s /opt/conda/bin/scif /usr/local/bin/scif

COPY ./varifier* /docker_context/
RUN scif install /docker_context/varifier.scif
COPY ./simutator* /docker_context/
RUN scif install /docker_context/simutator.scif    
COPY ./vcfdist* /docker_context/
RUN scif install /docker_context/vcfdist.scif       
COPY ./snippy* /docker_context/
RUN scif install /docker_context/snippy.scif   
COPY ./freebayes* /docker_context/
RUN scif install /docker_context/freebayes.scif 
COPY ./clockwork* /docker_context/
RUN scif install /docker_context/clockwork.scif 
COPY ./minos* /docker_context/
RUN scif install /docker_context/minos.scif 
COPY ./gramtools* /docker_context/
RUN scif install /docker_context/gramtools.scif 
COPY ./sratools* /docker_context/
RUN scif install /docker_context/sratools.scif 
COPY ./bwa* /docker_context/
RUN scif install /docker_context/bwa.scif 
COPY ./picard* /docker_context/
RUN scif install /docker_context/picard.scif 
COPY ./tabix* /docker_context/
RUN scif install /docker_context/tabix.scif 


COPY config.json /docker_context/
RUN --mount=type=secret,id=gh_token \
    curl https://$(cat /run/secrets/gh_token)@raw.githubusercontent.com/NSSAC/SciducTainer/refs/heads/main/sciduct.scif > /tmp/sciduct.scif 

RUN --mount=type=secret,id=gh_token \
   scif install /tmp/sciduct.scif

RUN rm -rf /run/secrets || true

RUN rm -rf /usr/share/dotnet /opt/ghc /usr/local/share/boost $AGENT_TOOLSDIRECTORY

ENTRYPOINT ["scif","--quiet"]

CMD ["shell"]