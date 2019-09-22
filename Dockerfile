FROM debian:7.9

MAINTAINER Maksim Rakitin <mrakitin@bnl.gov>

RUN echo "deb http://archive.debian.org/debian wheezy main\n\
deb-src http://archive.debian.org/debian wheezy main\n\
deb http://archive.debian.org/debian wheezy-backports main\n\
deb-src http://archive.debian.org/debian wheezy-backports main" > /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y  \
      alien \
      autoconf \
      build-essential \
      bzip2 \
      gcc \
      g++ \
      git \
      make \
      patch \
      tar \
      # downloaders
      wget curl \
      zlib1g-dev \
      sed \
      libreadline6-dev \
      libglib2.0-0 \
      libxext6 libxext-dev \
      libxrender1 libxrender-dev \
      libsm6 libsm-dev \
      libsmbclient-dev \
      tk-dev \
      libx11-6 libx11-dev \
      # needed by xrt (see https://github.com/NSLS-II/lightsource2-recipes/pull/676):
      libegl1-mesa \
      # gobject-introspection
      flex \
      # install extra packages for gobject-introspection package
      libffi-dev \
      libssl-dev \
      bison \
      # install packages for hkl
      gtk-doc-tools \
      # need an editor...
      vim \
      # and one for tom...
      emacs \
      # X11 support for some graphical packages
      xvfb \
      # killall and friends
      psmisc procps htop

# Set the Locale so conda doesn't freak out
# It is roughly this problem: http://stackoverflow.com/questions/14547631/python-locale-error-unsupported-locale-setting
# I don't remember exactly where I found this solution, but it took about 2 days of
# intense googling and trial-and-error
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && \
    apt-get install -y locales -qq && \
    locale-gen en_US.UTF-8 en_us && \
    dpkg-reconfigure locales && \
    dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

# Add the conda binary folder to the path
ENV PATH /opt/conda/bin:$PATH

# Actually install miniconda
RUN cd && \
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh --no-verbose && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda*.sh

ENV CONDARC_PATH /opt/conda/.condarc
ENV CONDARC $CONDARC_PATH
ENV PYTHONUNBUFFERED 1

RUN echo "binstar_upload: false\n\
always_yes: true\n\
show_channel_urls: true\n\
channels:\n\
- lightsource2-tag\n\
- defaults" > $CONDARC_PATH

# And set the correct environmental variable that lets us use it

RUN conda info
RUN conda config --show-sources
RUN conda list --show-channel-urls
RUN cat $CONDARC_PATH
RUN conda install python=3.7 ipython
RUN conda install conda conda-build anaconda-client conda-env conda-verify networkx slacker
RUN conda info
RUN conda config --show-sources
RUN conda list --show-channel-urls

# create a user, since we don't want to run as root
ENV USER=builder
RUN useradd -ms /bin/bash $USER
ENV HOME=/home/$USER
WORKDIR $HOME
RUN chown -Rv $USER: /opt/conda/
USER $USER
RUN cp -v $CONDARC_PATH $HOME

## Convenience for interactive debugging:

# bash-git-prompt:
RUN git clone https://github.com/magicmonty/bash-git-prompt.git $HOME/.bash-git-prompt --depth=1

# Dot files:
RUN cd && git clone https://github.com/mrakitin/dotfiles && \
    cp -v dotfiles/bashrc $HOME/.bashrc && \
    cp -v dotfiles/vimrc $HOME/.vimrc && \
    cp -v dotfiles/bash_history $HOME/.bash_history && \
    rm -rfv dotfiles/

RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> $HOME/.bashrc

ENV HISTFILE=$HOME/.bash_history
