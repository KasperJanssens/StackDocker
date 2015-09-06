FROM     ubuntu:14.04
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
    && apt-get clean

RUN update-locale LANG=en_US.UTF-8 LC_MESSAGES=POSIX LC_ALL=en_US.UTF-8

RUN wget https://www.haskell.org/ghc/dist/7.10.2/ghc-7.10.2-x86_64-unknown-linux-deb7.tar.bz2 && \
  tar xvfj ghc-7.10.2-x86_64-unknown-linux-deb7.tar.bz2 && \
  cd ghc-7.10.2 && \
  ./configure && \
  make install 

RUN wget https://www.haskell.org/cabal/release/cabal-1.22.3.0/Cabal-1.22.3.0.tar.gz && \
  tar xzvf Cabal-1.22.3.0.tar.gz && \
  cd Cabal-1.22.3.0 && \
  ghc --make Setup.hs && \
  ./Setup configure --user && \
  ./Setup build && \
  ./Setup install 

RUN rm -rfv Cabal-1.22.3.0*

RUN useradd developer -d /home/developer -m -s /bin/bash && \
    echo developer:developer | chpasswd && \
    usermod -a -G sudo developer

RUN su - developer -c "\
  wget https://www.haskell.org/cabal/release/cabal-install-1.22.3.0/cabal-install-1.22.3.0.tar.gz \
"

RUN su - developer -c "\
  tar xzvf cabal-install-1.22.3.0.tar.gz  && \
  cd cabal-install-1.22.3.0 && \
  ./bootstrap.sh  \
"

RUN su - developer -c "\
  echo \"PATH=${PATH}:/home/developer/.cabal/bin\" > /home/developer/.bashrc \
"

RUN rm -rfv cabal-install-1.22.3.0*

RUN su - developer -c "\
  export PATH=${PATH}:/home/developer/.cabal/bin && \
  cabal update && \
  cabal install stack \
"

RUN su - developer -c "\
  export PATH=${PATH}:/home/developer/.cabal/bin && \
  git clone https://github.com/commercialhaskell/stack-ide.git && \
  cd stack-ide && \
  git submodule update --init --recursive && \
  stack build --copy-bins \
"

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    apt-get install -y oracle-java8-installer

RUN wget http://download.jetbrains.com/idea/ideaIC-14.1.4.tar.gz

RUN tar -xvf ideaIC-14.1.4.tar.gz

RUN git clone git@github.com:KasperJanssens/intellij-haskforce.git -b stack
