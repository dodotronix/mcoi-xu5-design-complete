FROM ubuntu:20.04

# here we mount our shared directory
# WORKDIR /media

RUN apt-get update
RUN apt-get install -y python3 tofrodos gawk xvfb gcc git \
        make net-tools libncurses5-dev tftpd zlib1g-dev libssl-dev flex \
        bison libselinux1 gnupg wget diffstat chrpath socat xterm autoconf libtool tar \
        unzip texinfo zlib1g-dev gcc-multilib build-essential libsdl1.2-dev \
        libglib2.0-dev screen pax gzip locales libtinfo5 

RUN locale-gen en_US.UTF-8
