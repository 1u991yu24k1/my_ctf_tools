FROM ubuntu:20.04 

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Tokyo

RUN apt -y update && apt install -y \
    vim file gawk cpio zip unzip \
    flex bison build-essential git cmake libc6-dbg nasm \
    iproute2 iputils-ping libssl-dev libffi-dev wget netcat socat \
    python3 python3-distutils python3-dev python3-pip \
    ruby ruby-dev \
    gdb strace ltrace patchelf \
    tzdata --fix-missing && rm -rf /var/lib/apt/list/*

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
    
RUN python3 -m pip install -U pip && python3 -m pip install --no-cache-dir \
    pwntools z3-solver ropper unicorn keystone-engine capstone angr hexdump 

RUN mkdir -p /glibc/src && git clone git://sourceware.org/git/glibc.git /glibc/src
RUN gem install one_gadget seccomp-tools && rm -rf /var/lib/gems/2.*/cache/*

WORKDIR /root/
RUN wget -q https://raw.githubusercontent.com/bata24/gef/dev/install.sh -O- | bash
RUN wget -q https://raw.githubusercontent.com/1u991yu24k1/my_ctf_tools/main/gdb_init.txt -O /root/.gdbinit
RUN wget -q https://raw.githubusercontent.com/1u991yu24k1/my_ctf_tools/main/vimrc -O /root/.vimrc

## glibc heap exploit
COPY --from=skysider/glibc_builder64:2.23 /glibc/2.23/64 /glibc/2.23/64
COPY --from=skysider/glibc_builder64:2.27 /glibc/2.27/64 /glibc/2.27/64
COPY --from=skysider/glibc_builder64:2.31 /glibc/2.31/64 /glibc/2.31/64
COPY --from=skysider/glibc_builder64:2.33 /glibc/2.33/64 /glibc/2.33/64
