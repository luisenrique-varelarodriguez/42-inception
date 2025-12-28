FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy startup script
COPY tools/script.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/script.sh

# Expose ports
# 9443 for HTTPS
# 8000 for edge agent
EXPOSE 9443 8000

# Run startup script
CMD ["/usr/local/bin/script.sh"]
