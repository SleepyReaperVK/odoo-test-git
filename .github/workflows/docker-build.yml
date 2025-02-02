# Use the official Odoo image directly
FROM odoo:16.0

# Add any custom configurations if needed
COPY ./config /etc/odoo
COPY ./addons /mnt/extra-addons

# Expose the port
EXPOSE 8069

# The CMD is inherited from the base image
