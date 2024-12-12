# FROM ghcr.io/nssac/mambascif as mamba_scif_install
FROM vanessa/scif-go AS scifgo
FROM ghcr.io/iqbal-lab-org/minos AS minos
FROM ghcr.io/iqbal-lab-org/clockwork

ARG VERSION
ENV VERSION=${VERSION:-0.0.0}

RUN apt-get update && \
    apt-get install --assume-yes \
    curl \
    git \
    jq \
    tree \
    musl-dev \
    && apt-get clean --assume-yes

# Don't fail on first-time host key check for any %appinstall
# needing to clone code from Github.
RUN mkdir -p /etc/ssh
RUN echo "StrictHostKeyChecking accept-new" >> /etc/ssh/ssh_config

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#setup mamba and scif
ENV ENV_NAME="base"
ENV MAMBA_EXE="/bin/micromamba"
RUN pip3 install --upgrade requests

# for scif go
RUN ln -s /usr/lib/x86_64-linux-musl/libc.so /lib/libc.musl-x86_64.so.1
COPY --from=scifgo /usr/local/bin/scif /usr/bin/

COPY /installmamba.sh /opt/
RUN /opt/installmamba.sh && rm /opt/installmamba.sh
ENV MAMBA_ROOT_PREFIX="/opt/conda"

# build mamba 'base' env
RUN micromamba install --name $ENV_NAME python=3.11 -y -c conda-forge && \
    micromamba run --name $ENV_NAME pip install ipython jsonschema 

COPY ./snippy* /docker_context/
RUN scif install /docker_context/snippy.scif   
COPY ./freebayes* /docker_context/
RUN scif install /docker_context/freebayes.scif 
COPY ./bwa* /docker_context/
RUN scif install /docker_context/bwa.scif 
COPY ./picard* /docker_context/
COPY ./picard.sh /bioinf-tools/picard
RUN scif install /docker_context/picard.scif 
COPY ./tabix* /docker_context/
RUN scif install /docker_context/tabix.scif 

# copy the gramtools from minos becuase the one from clockwork is broken (ldd gram)
# the one from minus is already compiled, just needs to be installed
# It links against the correct htslib
COPY --from=minos /bioinf-tools/gramtools /bioinf-tools/gramtools
RUN cd /bioinf-tools/gramtools && pip3 install -e .

COPY ./clockwork* /docker_context/
RUN scif install /docker_context/clockwork.scif 
COPY ./minos* /docker_context/
RUN scif install /docker_context/minos.scif 
COPY ./gramtools* /docker_context/
RUN scif install /docker_context/gramtools.scif 

COPY src /src
COPY ./variantiq* /docker_context/
RUN scif install /docker_context/variantiq.scif 
# RUN rm -rf /src

COPY config.json /docker_context/
RUN --mount=type=secret,id=gh_token \
    curl https://$(cat /run/secrets/gh_token)@raw.githubusercontent.com/NSSAC/SciducTainer/refs/heads/main/sciduct.scif > /tmp/sciduct.scif 

RUN --mount=type=secret,id=gh_token \
   scif install /tmp/sciduct.scif

RUN rm -rf /run/secrets || true

RUN rm -rf /usr/share/dotnet /opt/ghc /usr/local/share/boost $AGENT_TOOLSDIRECTORY /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["scif","--quiet"]

CMD ["shell"]