FROM debian:trixie-slim AS mpq-extractor-builder-debian
RUN <<EOF
set -eux
apt-get update
apt-get install -y --no-install-recommends --no-install-suggests build-essential zlib1g-dev libbz2-dev cmake
rm -rf /var/lib/apt/lists/*
EOF

COPY . /src

RUN <<EOF
set -eux
mkdir /build
cd /build
cmake /src
cmake --build .
EOF

WORKDIR /build

ENTRYPOINT ["/bin/bash"]

ENV PATH=/build/bin:$PATH

FROM debian:trixie-slim AS mpq-extractor-debian

COPY --from=mpq-extractor-builder-debian /build/bin/MPQExtractor /usr/local/bin

WORKDIR /opt/data

ENTRYPOINT ["/usr/local/bin/MPQExtractor"]
