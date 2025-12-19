#!/bin/bash

# Script to renew Let's Encrypt certificates
# This should be run via cron: 0 3 * * * /path/to/renew-cert.sh

docker compose -f docker-compose.prod.yml run --rm certbot renew
docker compose -f docker-compose.prod.yml exec nginx-proxy nginx -s reload


