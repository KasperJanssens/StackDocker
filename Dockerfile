FROM     ubuntu:16.04
MAINTAINER Kasper Janssens

RUN echo "Europe/Brussels" > "/etc/timezone"

RUN apt-get update -q && apt-get install -y \
    libbsd-dev \
    git \
    libgmp-dev \
    zlib1g-dev \
    wget \
    make \
    language-pack-en-base \
    locales \
    libpcre3-dev \
    software-properties-common \
    openssh-server \
    libxext-dev \
    libxrender-dev \
    libxtst-dev \
    libfontconfig1 \
    build-essential \
    curl \
    sudo \
    && apt-get clean

RUN update-locale LANG=en_US.UTF-8 LC_MESSAGES=POSIX LC_ALL=en_US.UTF-8

RUN wget https://downloads.haskell.org/~ghc/8.2.1/ghc-8.2.1-x86_64-deb8-linux.tar.xz && \
  tar xvf ghc-8.2.1-x86_64-deb8-linux.tar.xz && \
  cd ghc-8.2.1 && \
  ./configure && \
  make install 

RUN wget https://www.haskell.org/cabal/release/cabal-2.0.0.2/Cabal-2.0.0.2.tar.gz && \
  tar xzvf Cabal-2.0.0.2.tar.gz && \
  cd Cabal-2.0.0.2 && \
  ghc --make Setup.hs && \
  ./Setup configure --user && \
  ./Setup build && \
  ./Setup install 

RUN rm -rfv Cabal-2.0.0.2*

RUN useradd developer -d /home/developer -m -s /bin/bash && \
    echo developer:developer | chpasswd && \
    usermod -a -G sudo developer

RUN echo "developer ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN su - developer -c "\
  wget https://www.haskell.org/cabal/release/cabal-install-2.0.0.0/cabal-install-2.0.0.0.tar.gz \
"

RUN su - developer -c "\
  tar xzvf cabal-install-2.0.0.0.tar.gz  && \
  cd cabal-install-2.0.0.0 && \
  ./bootstrap.sh  \
"

RUN su - developer -c "\
  echo \"PATH=${PATH}:/home/developer/.cabal/bin\" > /home/developer/.bashrc \
"

RUN rm -rfv cabal-install-2.0.0.0*

RUN wget -qO- https://get.haskellstack.org/ | sh

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    apt-get install -y oracle-java8-installer

RUN su - developer -c "\
  curl -L https://git.io/haskell-vim-now > /tmp/haskell-vim-now.sh && \
"
