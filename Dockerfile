FROM jruby:9.1.12.0

ENV BUILD_PACKAGES="bash build-essential curl git" \
    CARGO_HOME=/usr/local/cargo \
    DEL_PACKAGES="build-essential" \
    HOME=/root \
    RUBY_APP_ROOT=/app/ruby_wrapper \
    RUST_LIB_ROOT=/app/rusty_lib \
    APP_HOME=/app \
    LC_ALL=C.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    PATH=/usr/local/cargo/bin:$PATH \
    RUSTUP_URL="https://sh.rustup.rs" \
    RUSTUP_HOME=/usr/local/rustup \
    RUST_LIB_NAME=librusty.lib

RUN apt-get update -q && \
    apt-get dist-upgrade -y && \
# -- Install build dependencies:
    if [ -n "${BUILD_PACKAGES}" ]; then apt-get install -y $BUILD_PACKAGES; fi && \
# -- Install Rust
    curl -sSf "${RUSTUP_URL}" > rustup-init.sh && \
    chmod +x rustup-init.sh && \
    ./rustup-init.sh -y --no-modify-path && \
    rm rustup-init.sh && \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME && \
    rustup --version && \
    cargo --version  && \
    rustc --version

RUN mkdir $APP_HOME
COPY . $APP_HOME/

# -- Build rust library
WORKDIR $RUST_LIB_ROOT
RUN cargo build --release && \
    mkdir $RUBY_APP_ROOT/ffi/ && \
    cp $RUST_LIB_ROOT/target/release/librusty.so $RUBY_APP_ROOT/ffi/$RUST_LIB_NAME

WORKDIR $RUBY_APP_ROOT

RUN bundle install && \
# -- Purge build tooling
    rm -rf /usr/local/rustup/toolchains && \
    rm -rf /usr/local/cargo/registry && \
# -- Purge required build tools
    if [ -n "${DEL_PACKAGES}" ]; then apt-get purge -y --auto-remove $DEL_PACKAGES ; fi && \
    apt-get clean -y

CMD ["bin/console"]