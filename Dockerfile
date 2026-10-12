FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install foundational networking tools and runtime libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    nmap \
    iputils-ping \
    dnsutils \
    net-tools \
    curl \
    ca-certificates \
    git \
    procps \
    libpcap0.8 \
    gcc \
    python3-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, install ptmanager and all Penterep AST tools
COPY tools.txt /tools.txt
RUN pip install --upgrade pip setuptools wheel && \
    pip install ptmanager && \
    pip install --no-cache-dir -r /tools.txt && \
    apt-get purge -y --auto-remove gcc python3-dev libssl-dev && \
    rm -rf /var/lib/apt/lists/* /root/.cache

# Create persistent state directory and workspace
RUN mkdir -p /root/.penterep /workspace
WORKDIR /workspace

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
