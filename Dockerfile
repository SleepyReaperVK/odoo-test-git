# Use Ubuntu latest as base image
FROM ubuntu:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    python3-wheel \
    python3-setuptools \
    libxml2-dev \
    libxslt1-dev \
    libldap2-dev \
    libsasl2-dev \
    libpq-dev \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    postgresql-client \
    nodejs \
    npm \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf for report generation
RUN apt-get update && apt-get install -y wkhtmltopdf && rm -rf /var/lib/apt/lists/*

# Install Odoo
RUN git clone --depth 1 --branch 16.0 https://github.com/odoo/odoo.git /odoo

# Install Python dependencies with --no-cache-dir to keep image size down
RUN pip3 install --no-cache-dir wheel
RUN pip3 install --no-cache-dir -r /odoo/requirements.txt

# Set working directory
WORKDIR /odoo

# Odoo configuration
ENV ODOO_RC=/etc/odoo/odoo.conf

# Create Odoo user
RUN useradd -m -d /var/lib/odoo -U -r -s /bin/bash odoo

# Create necessary directories
RUN mkdir -p /var/lib/odoo \
    && mkdir -p /mnt/extra-addons \
    && mkdir -p /etc/odoo

# Set permissions
RUN chown -R odoo:odoo /var/lib/odoo \
    && chown -R odoo:odoo /mnt/extra-addons \
    && chown -R odoo:odoo /etc/odoo \
    && chown -R odoo:odoo /odoo

# Switch to odoo user
USER odoo

# Expose Odoo ports
EXPOSE 8069 8071 8072

# Set the default command to run Odoo
CMD ["/odoo/odoo-bin", "-c", "/etc/odoo/odoo.conf"]
