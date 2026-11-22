# Nodulz

Deploy Nodulz with Helm: https://nodulz.com/docs/self-host-kubernetes

Choose SQLite with a persistent volume or an external PostgreSQL, MySQL 8.4 or MariaDB 11.4 database. The chart runs one replica. Set publicUrl to the URL used by clients and configure ingress for remote access.

Set existingSecret to a Secret containing ADMIN_USERNAME, ADMIN_EMAIL and ADMIN_PASSWORD for the initial administrator, plus BETTER_AUTH_SECRET and CREDENTIALS_ENCRYPTION_KEY for all database drivers. External databases also need DATABASE_URL. Follow the [environment configuration guide](https://nodulz.com/docs/self-host-configuration#environment-file) to prepare the values and generate two independent keys. Account variables only apply to an empty instance; changing them does not reset an existing account.

For MySQL or MariaDB use a dedicated empty InnoDB database and a schema-scoped migration account with privileges for tables, indexes, references and triggers. When binary logging restricts trigger creation, have the database administrator enable `log_bin_trust_function_creators` before installation. Use `mysql://nodulz:PASSWORD@host:3306/nodulz?ssl-mode=VERIFY_IDENTITY` for verified TLS.

Back up the database, application volume and original secrets before upgrading. The application volume includes instance-secrets.json; keep its keys unchanged when restoring or reusing existing data. Uninstalling retains the chart's PVC; reuse it with persistence.existingClaim.
