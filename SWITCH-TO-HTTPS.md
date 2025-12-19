# How to Switch Back to HTTPS Config

## Current Status
Your `docker-compose.prod.yml` is currently using the HTTP-only config (line 88).

## To Switch Back to HTTPS (after certificates are obtained):

### Step 1: Verify certificates exist

Check if certificates are in the certbot volume:
```bash
docker compose -f docker-compose.prod.yml run --rm certbot ls -la /etc/letsencrypt/live/getshrug.app/
```

You should see:
- `fullchain.pem`
- `privkey.pem`

### Step 2: If certificates exist, switch to HTTPS config

Edit `docker-compose.prod.yml` and change **line 88** from:
```yaml
- ./nginx/docker/nginx-http-only.conf:/etc/nginx/conf.d/default.conf:ro
```

To:
```yaml
- ./nginx/docker/nginx.conf:/etc/nginx/conf.d/default.conf:ro
```

### Step 3: Restart nginx-proxy

```bash
docker compose -f docker-compose.prod.yml up -d --force-recreate nginx-proxy
```

### Step 4: Verify nginx started

```bash
docker compose -f docker-compose.prod.yml ps nginx-proxy
```

Should show "Up" (not "Restarting").

---

## If Certificates Don't Exist:

You need to get them first using the HTTP-only config:

1. Make sure nginx is running with HTTP-only config (current state)
2. Run the Let's Encrypt init script:
   ```bash
   chmod +x nginx/scripts/init-letsencrypt.sh
   ./nginx/scripts/init-letsencrypt.sh
   ```
3. After certificates are obtained, follow Steps 2-4 above to switch to HTTPS config

