FROM docker.io/library/debian:11.9 as build
RUN apt -y update && apt -y install musl-tools curl git build-essential wget
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh
RUN sh /tmp/rustup.sh -y
RUN mkdir -p /tmp/build
WORKDIR /tmp/build
RUN git clone https://github.com/richfelker/musl-cross-make
WORKDIR /tmp/build/musl-cross-make
RUN echo TARGET = arm-linux-musleabihf>config.mak
RUN make -j && make install
WORKDIR /
FROM docker.io/library/debian:11.9 as target
COPY --from=build /tmp/build/musl-cross-make/output/ /usr/local
RUN apt -y update && apt -y install musl-tools curl git build-essential &&\
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh && sh /tmp/rustup.sh -y && rm /tmp/rustup.sh
ENV PATH="$PATH:/root/.cargo/bin"
RUN rustup target add x86_64-unknown-linux-musl arm-unknown-linux-musleabihf
