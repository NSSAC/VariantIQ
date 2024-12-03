FROM ghcr.io/iqbal-lab-org/minos as minos
FROM ghcr.io/nssac/mambascif 

ARG VERSION
ENV VERSION=${VERSION:-0.0.0}

RUN apt-get update && \
    apt-get install --assume-yes \
    curl \
    git \
    jq \
    libquadmath0 \
    tree \
    zlib1g-dev \
    samtools \
    gcc \
    g++ \
    build-essential \
    cmake \
    clang \
    clang-tools \
    cython3 \
    python3-pysam \
    libbz2-dev \
    liblzma-dev \
    python3-pybedtools \
    python3-pip \
    libcrypto++-dev \
    python3-pip \
    libcurl4-openssl-dev && \
    apt-get clean --assume-yes

RUN pip install --break-system-packages "setuptools<58.0.0" 
RUN pip install --break-system-packages git+https://github.com/iqbal-lab-org/gramtools.git
RUN mkdir /scif_files
COPY ./*.scif /docker_context/
COPY ./*.yml /docker_context/
RUN ls /docker_context
# Don't fail on first-time host key check for any %appinstall
# needing to clone code from Github.
RUN echo "StrictHostKeyChecking accept-new" >> /etc/ssh/ssh_config

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
ENV PATH="${MAMBA_ROOT_PREFIX}/bin:${PATH}"
ENV LD_LIBRARY_PATH=/usr/lib:/usr/lib/x86_64-linux-gnu/:/usr/local/lib/:/opt/conda/lib
RUN ln -s /lib/x86_64-linux-gnu/libcrypto.so.3 /lib/x86_64-linux-gnu/libcrypto.so
RUN mkdir /bioinf-tools 

RUN --mount=type=secret,id=gh_token \
  ls -la /run/secrets

RUN rm -rf /usr/share/dotnet /opt/ghc /usr/local/share/boost $AGENT_TOOLSDIRECTORY

RUN scif install /docker_context/variantiq.scif

RUN scif install /docker_context/minos.scif

RUN scif install /docker_context/varifier.scif

RUN scif install /docker_context/simutator.scif    

RUN scif install /docker_context/vcfdist.scif       

RUN scif install /docker_context/snippy.scif   

RUN scif install /docker_context/freebayes.scif 

RUN scif install /docker_context/clockwork.scif     

COPY config.json /docker_context/

RUN --mount=type=secret,id=gh_token \
    curl https://$(cat /run/secrets/gh_token)@raw.githubusercontent.com/NSSAC/SciducTainer/refs/heads/main/sciduct.scif > /tmp/sciduct.scif 

RUN --mount=type=secret,id=gh_token \
   scif install /tmp/sciduct.scif


RUN rm -rf /run/secrets || true

RUN apt-get remove --assume-yes \
    gcc \
    g++ \
    build-essential \
    cmake \
    clang \
    clang-tools \
    cython3   

ENTRYPOINT ["scif"]

CMD ["shell"]