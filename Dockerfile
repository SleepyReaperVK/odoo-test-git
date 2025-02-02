# Use Ubuntu latest as base image
FROM ubuntu:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install Odoo dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    postgresql-client \
    nodejs \
    npm \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Odoo
RUN git clone --depth 1 --branch 16.0 https://github.com/odoo/odoo.git /odoo

# Install Python dependencies
RUN pip3 install -r /odoo/requirements.txt

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
    && chown -R odoo:odoo /etc/odoo

# Expose Odoo ports
EXPOSE 8069 8071 8072

# Set the default command to run Odoo
CMD ["/odoo/odoo-bin", "-c", "/etc/odoo/odoo.conf"]
