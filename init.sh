#!/bin/sh
set -eu
umask 077
if [ -e .env ]; then echo '.env already exists; no changes made.' >&2; exit 1; fi
command -v openssl >/dev/null || { echo 'Install openssl first.' >&2; exit 1; }
printf 'Published Nodulz version (X.Y.Z): '; read -r version
printf '%s' "$version" | grep -Eq '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$' || { echo 'Invalid version' >&2; exit 1; }
printf 'Public URL [http://localhost:3001]: '; read -r url
url="${url:-http://localhost:3001}"
url="${url%/}"
printf '%s' "$url" | grep -Eq '^(https://[a-zA-Z0-9][a-zA-Z0-9.-]*(:[0-9]+)?|http://localhost:[0-9]+)$' || { echo 'Use an HTTPS origin or http://localhost:PORT without a path.' >&2; exit 1; }
printf 'Administrator email: '; read -r email
printf '%s' "$email" | grep -Eq '^[a-zA-Z0-9._+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' || { echo 'Invalid email' >&2; exit 1; }
auth=$(openssl rand -hex 32)
encryption=$(openssl rand -hex 32)
admin=$(openssl rand -hex 24)
postgres=$(openssl rand -hex 24)
(set -C; printf 'NODULZ_VERSION=%s\nNODULZ_PUBLIC_URL=%s\nADMIN_EMAIL=%s\nBETTER_AUTH_SECRET=%s\nCREDENTIALS_ENCRYPTION_KEY=%s\nADMIN_PASSWORD=%s\nPOSTGRES_PASSWORD=%s\n' "$version" "$url" "$email" "$auth" "$encryption" "$admin" "$postgres" > .env)
echo 'Created .env. Keep it private and back it up with your data.'
