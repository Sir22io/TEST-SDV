# Multi-stage build for production
FROM kalilinux/kali-rolling:latest as builder

# Metadata
LABEL maintainer="cybertoolbox-pro@example.com"
LABEL version="1.0.0"
LABEL description="CyberToolbox Pro - Automated Penetration Testing Platform"

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Python and pip
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    # Build tools
    build-essential \
    gcc \
    g++ \
    make \
    # System utilities
    curl \
    wget \
    git \
    unzip \
    # Network tools
    netcat-traditional \
    iputils-ping \
    # Kali penetration testing tools
    nmap \
    metasploit-framework \
    sqlmap \
    hydra \
    john \
    openvas \
    burpsuite \
    aircrack-ng \
    clamav \
    nikto \
    dirb \
    gobuster \
    masscan \
    # Database clients
    postgresql-client \
    redis-tools \
    # SSL/TLS tools
    openssl \
    ca-certificates \
    # Process management
    supervisor \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install wheel
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy requirements and install Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Stage 2: Production image
FROM kalilinux/kali-rolling:latest

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    curl \
    # Kali tools (runtime only)
    nmap \
    metasploit-framework \
    sqlmap \
    hydra \
    john \
    openvas \
    burpsuite \
    aircrack-ng \
    clamav \
    nikto \
    dirb \
    gobuster \
    masscan \
    # Database clients
    postgresql-client \
    redis-tools \
    # SSL certificates
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user
RUN groupadd -r cybertoolbox && \
    useradd -r -g cybertoolbox -d /app -s /bin/bash cybertoolbox && \
    mkdir -p /app /app/logs /app/reports /app/data && \
    chown -R cybertoolbox:cybertoolbox /app

# Set working directory
WORKDIR /app

# Copy application code
COPY --chown=cybertoolbox:cybertoolbox src/backend/ /app/
COPY --chown=cybertoolbox:cybertoolbox templates/ /app/templates/
COPY --chown=cybertoolbox:cybertoolbox configs/ /app/configs/
COPY --chown=cybertoolbox:cybertoolbox scripts/ /app/scripts/

# Make scripts executable
RUN chmod +x /app/scripts/*.sh

# Create necessary directories
RUN mkdir -p /app/logs /app/reports /app/uploads /app/backups && \
    chown -R cybertoolbox:cybertoolbox /app

# Switch to non-root user
USER cybertoolbox

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Default command
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
