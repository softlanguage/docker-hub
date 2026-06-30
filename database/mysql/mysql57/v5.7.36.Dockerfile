# docker build -t softlang/mysql:v5.7.36-zstd -f v5.7.36.Dockerfile .
FROM softlang/mysql:v5.7.36

# Use faster archive mirrors, install zstd and gettext, then clean up apt cache.
RUN set -eux; \
    sed -i \
    "s|http://[^/]*.debian.org|http://mirrors.cloud.aliyuncs.com/debian-archive|g; \
    s|http://archive.ubuntu.com|http://mirrors.aliyun.com|g; \
    s|http://security.ubuntu.com|http://mirrors.aliyun.com|g" \
    /etc/apt/sources.list 2>/dev/null || true; \
    apt-get update -qq; \
    apt-get install -y -qq --no-install-recommends \
    zstd \
    gettext; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*
