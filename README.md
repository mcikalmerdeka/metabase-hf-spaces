---
title: Metabase Dashboard
sdk: docker
app_port: 3000
---

# Metabase on Hugging Face Spaces

A complete guide for deploying Metabase on Hugging Face Spaces with a Neon PostgreSQL database.

**Live URL:** https://mcikalmerdeka-metabase-hf-space.hf.space

## What This Project Does

This Space hosts a Metabase Business Intelligence instance connected to an external Neon PostgreSQL database. All Metabase application data (dashboards, questions, users, settings) is persisted in Neon, making the deployment stateless and portable.

## Architecture

```
User → Hugging Face Spaces (Docker container)
           ↓
    Metabase v0.61 (port 3000)
           ↓
    Neon PostgreSQL (persistent app DB)
```

## Quick Start (for future deployments)

### Step 1: Create Hugging Face Space

1. Go to https://huggingface.co/new-space
2. Fill in Space Name (e.g., `my-metabase`)
3. Select **Docker** as SDK
4. Choose **Blank** template
5. Set visibility (Public or Private)
6. Create Space

### Step 2: Configure Secrets

Go to Space Settings → **Variables and Secrets**

**Required Secrets:**

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `MB_DB_TYPE` | Database type | `postgres` |
| `MB_DB_HOST` | Neon host | `ep-xxx-pooler.c-2.us-east-1.aws.neon.tech` |
| `MB_DB_PORT` | Database port | `5432` |
| `MB_DB_DBNAME` | Database name | `neondb` |
| `MB_DB_USER` | Database user | `neondb_owner` |
| `MB_DB_PASS` | Database password | `npg_xxxx` |

**IMPORTANT: Do NOT set `MB_DB_CONNECTION_URI` unless you use a full JDBC URL.**

### Step 3: Set GitHub Actions

1. Create `.github/workflows/sync-to-hub.yml`
2. Add your HF Space repo ID: `huggingface_repo_id: YOUR_USERNAME/YOUR_SPACE_NAME`
3. Ensure `HF_TOKEN` secret is set in your GitHub repo settings

### Step 4: Create Files

**Dockerfile:**
```dockerfile
FROM metabase/metabase:latest
# The base image already has ENTRYPOINT configured.
# Do NOT add CMD — it will be passed as an argument to the entrypoint.
EXPOSE 3000
```

**README.md:** (this file)

### Step 5: Deploy

```bash
git add .
git commit -m "feat: deploy metabase"
git push origin main
```

The GitHub Action will automatically sync to your HF Space and trigger a build.

## Common Errors & How to Fix Them

### Error 1: `No suitable driver found for jdbc:sslmode=require`

**Cause:** You set `MB_DB_CONNECTION_URI = sslmode=require` (or any partial value).

**What happens:** Metabase treats ANY non-empty `MB_DB_CONNECTION_URI` as the full connection string. It prepends `jdbc:` to your value, creating `jdbc:sslmode=require` which is invalid.

**Fix:** Delete the `MB_DB_CONNECTION_URI` secret entirely. Use individual `MB_DB_HOST`, `MB_DB_PORT`, etc. instead. The PostgreSQL JDBC driver automatically negotiates SSL with Neon.

### Error 2: `Unrecognized command: '/app/run_metabase.sh'`

**Cause:** Your Dockerfile had `CMD ["/app/run_metabase.sh"]`.

**What happens:** The official Metabase image already has `ENTRYPOINT ["/app/run_metabase.sh"]` configured. Adding `CMD` passes it as an argument to the entrypoint, so Metabase tries to run `/app/run_metabase.sh /app/run_metabase.sh` and interprets the second one as a CLI command.

**Fix:** Remove `CMD` from your Dockerfile. Only use:
```dockerfile
FROM metabase/metabase:latest
EXPOSE 3000
```

### Error 3: `mcikalmerdeka-metabase-hf-space.hf.space refused to connect`

**Cause:** The HF Spaces proxy gets confused when the container restarts during long migrations.

**What happens:** Metabase takes ~2 minutes for initial DB migrations. HF Spaces may restart the container if it appears "stuck", leaving the proxy in a bad state.

**Fix:**
1. Go to your Space settings
2. Click **"Factory Restart"**
3. Wait for the status badge to show **"Running"**
4. Access the direct URL: `https://YOUR_SPACE_NAME.hf.space`

**Note:** The embedded App tab inside HF Spaces may not always display correctly, but the direct `.hf.space` URL always works when the Space is Running.

## Troubleshooting Checklist

If your deployment isn't working:

- [ ] Secrets are set as **Secrets** (not Variables) in HF Space settings
- [ ] `MB_DB_CONNECTION_URI` is either deleted or contains a FULL JDBC URL
- [ ] Dockerfile does NOT contain `CMD` — only `FROM` and `EXPOSE`
- [ ] GitHub Action uses correct `huggingface_repo_id` format: `username/space-name`
- [ ] `HF_TOKEN` secret is set in GitHub repo settings
- [ ] Space status badge shows "Running" (not "Building" or "Paused")
- [ ] Accessing the direct `.hf.space` URL, not just the App tab
- [ ] Neon database allows connections from your IP (check Neon connection pooler settings)
- [ ] Neon database is active (not suspended due to inactivity)

## Neon Database Tips

### Connection String Format
If you prefer using a connection URI instead of individual params:
```
jdbc:postgresql://HOST:5432/DBNAME?sslmode=require
```

**Note:** You must use the JDBC format (`jdbc:postgresql://...`), NOT the `postgresql://` format. Metabase normalizes `postgres://` to `jdbc:postgresql://` but for safety, use the JDBC prefix directly.

### Getting Your Neon Connection Info
1. Go to your Neon project dashboard
2. Click "Connection Details"
3. Copy the connection string and extract host, dbname, user, password

## Useful Resources

- [Metabase Docker Docs](https://www.metabase.com/docs/latest/installation-and-operation/running-metabase-on-docker)
- [Hugging Face Spaces Docs](https://huggingface.co/docs/hub/spaces)
- [Neon + Metabase Guide](https://neon.com/guides/metabase-neon)
- [GitHub Actions for HF Spaces](https://huggingface.co/docs/hub/spaces-github-actions)

## Configuration Summary

- **SDK:** Docker
- **App Port:** 3000
- **Base Image:** `metabase/metabase:latest`
- **Database:** Neon PostgreSQL
- **CI/CD:** GitHub Actions → Hugging Face Hub
- **Space Status:** https://huggingface.co/spaces/mcikalmerdeka/metabase-hf-space

---

Last updated: May 2026
