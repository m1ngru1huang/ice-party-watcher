# Rust as the base image
FROM rust:latest as builder
 
RUN apt update; apt upgrade -y 
RUN apt install -y g++-arm-linux-gnueabihf libc6-dev-armhf-cross
RUN apt install pkg-config -y
RUN apt-get install libssl-dev -y
 
RUN rustup target add aarch64-unknown-linux-gnu 
RUN rustup toolchain install stable-aarch64-unknown-linux-gnu 

# Create a new empty shell project
RUN USER=root cargo new --bin ice-party-watch
WORKDIR /ice-party-watch

# Copy our manifests
COPY ./Cargo.toml ./Cargo.toml
COPY ./Cargo.lock ./Cargo.lock
COPY ./.cargo ./.cargo

ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc \
    CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc \
    CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++

RUN PKG_CONFIG_SYSROOT_DIR=/

# Build only the dependencies to cache them
RUN cargo build --release --target aarch64-unknown-linux-gnu
RUN rm ./src/*.rs


# Copy the source code
COPY ./src ./src

RUN cargo build --release --target aarch64-unknown-linux-gnu

FROM scratch
WORKDIR /ice-party-watch 
COPY --from=builder /ice-party-watch/target/armv7-unknown-linux-gnueabihf/release/ice-party-watch .

CMD ["./ice-party-watch"]
