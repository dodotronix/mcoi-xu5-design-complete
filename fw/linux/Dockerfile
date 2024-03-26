FROM ubuntu:20.04 
LABEL version="0.1" description="PetaLinux image"

RUN dpkg --add-architecture i386 && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  autoconf \
  bc \
  bison \
  build-essential \
  chrpath \
  cpio \
  diffstat \
  dos2unix \
  expect \
  fakeroot \
  flex \
  gawk \
  gcc-7 \
  gcc-multilib \
  git \
  xterm \
  gnupg \
  gzip \
  iproute2 \
  less \
  libglib2.0-dev \
  libgtk2.0-0 \
  libgtk2.0-dev \
  libncurses5-dev \
  libsdl1.2-dev \
  libselinux1 \
  libssl-dev \
  libtinfo5 \
  libtool \
  libtool-bin \
  locales \
  lsb-release \
  make \
  net-tools \
  pax \
  rsync \
  socat \
  software-properties-common \
  sudo \
  tar \
  texinfo \
  tofrodos \
  unzip \
  update-inetd \
  vim \
  wget \
  zlib1g-dev \
  zlib1g-dev:i386 \
  python2 \
  python3 \
  && apt-get autoremove --purge \
  && apt-get autoclean


# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# set bash as default shell
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Add user petalinux'
RUN useradd -m petalinux \
  && chmod +w /opt \
  && chown -R petalinux:petalinux /opt \
  && mkdir /opt/petalinux \
  && chmod 755 /opt/petalinux \
  && chown petalinux:petalinux /opt/petalinux 

# Install under /opt, with user petalinux
USER petalinux
WORKDIR /opt

# Install PetaLinux
COPY --chown=petalinux:petalinux petalinux-*-installer.run .
ARG SKIP_LICENSE=y
RUN chmod +x *.run \
  && ls -1 *.run | xargs -I{} bash -c './{} -d ./petalinux' \
  && rm *.run

# Volume for the project files
VOLUME /home/petalinux/build


# Source settings at login
RUN echo "source /opt/petalinux/settings.sh" >> /home/petalinux/.bashrc

ENV SHELL /usr/bin/bash
WORKDIR /home/petalinux/build
USER petalinux


ENTRYPOINT ["/usr/bin/bash", "-l"]
