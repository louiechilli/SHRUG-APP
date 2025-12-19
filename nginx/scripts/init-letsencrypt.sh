#!/bin/bash

# Script to initialize Let's Encrypt certificates
# Usage: ./init-letsencrypt.sh

if ! [ -x "$(command -v docker compose)" ]; then
  echo 'Error: docker compose is not installed.' >&2
  exit 1
fi

domains=(getshrug.app www.getshrug.app api.getshrug.app)
rsa_key_size=4096
data_path="./nginx/certbot"
email="admin@getshrug.app" # Change this to your email
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for ${domains[*]}. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Ensuring nginx is running with HTTP-only config ..."
# Start nginx with HTTP-only config (should already be running, but ensure it is)
docker compose -f docker-compose.prod.yml up -d nginx-proxy
echo

echo "### Requesting Let's Encrypt certificate for ${domains[*]} ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker compose -f docker-compose.prod.yml run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker compose -f docker-compose.prod.yml exec nginx-proxy nginx -s reload
echo

echo "### IMPORTANT: Next steps ..."
echo "1. Certificates have been successfully obtained!"
echo "2. Update docker-compose.prod.yml to use nginx.conf instead of nginx-http-only.conf"
echo "3. Restart nginx-proxy: docker compose -f docker-compose.prod.yml up -d --force-recreate nginx-proxy"
echo "4. Set Cloudflare SSL/TLS mode to 'Full' or 'Full (strict)'"
echo ""

