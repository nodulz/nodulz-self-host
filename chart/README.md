# Nodulz

Deploy Nodulz with Helm: https://nodulz.com/docs/self-host-kubernetes

Choose SQLite with a persistent volume or an external PostgreSQL database. The chart runs one replica. Set publicUrl to the URL used by clients and configure ingress for remote access.

Set existingSecret to a Secret containing ADMIN_USERNAME, ADMIN_EMAIL and ADMIN_PASSWORD for the initial administrator, plus BETTER_AUTH_SECRET and CREDENTIALS_ENCRYPTION_KEY for both SQLite and PostgreSQL. PostgreSQL also needs DATABASE_URL. Follow the [environment configuration guide](https://nodulz.com/docs/self-host-configuration#environment-file) to prepare the values and generate two independent keys. Account variables only apply to an empty instance; changing them does not reset an existing account.

Back up the database, application volume and original secrets before upgrading. The application volume includes instance-secrets.json; keep its keys unchanged when restoring or reusing existing data. Uninstalling retains the chart's PVC; reuse it with persistence.existingClaim.
