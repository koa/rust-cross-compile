FROM docker.io/library/rust:1.75.0 as build
#RUN rustup target add x86_64-unknown-linux-musl
#RUN apt -y update && apt -y install musl-tools
RUN mkdir -p /tmp/build
WORKDIR /tmp/build
RUN git clone https://github.com/richfelker/musl-cross-make
WORKDIR /tmp/build/musl-cross-make
RUN echo TARGET = arm-linux-musleabihf>config.mak
RUN make -j && make install
WORKDIR /
FROM docker.io/library/rust:1.75.0 as target
COPY --from=build /tmp/build/musl-cross-make/output/ /usr/local
RUN rustup target add x86_64-unknown-linux-musl armv7-unknown-linux-musleabihf
RUN apt -y update && apt -y install musl-tools
