---
title: Metabase Dashboard
sdk: docker
app_port: 3000
---

# Metabase Dashboard

This Space hosts a Metabase instance connected to a Neon PostgreSQL database.

## Deployment

This application is automatically deployed to Hugging Face Spaces via GitHub Actions on every push to the `main` branch.

## Configuration

Database credentials and other sensitive configuration are stored as Secrets in the Hugging Face Space settings.

- **SDK**: Docker
- **App Port**: 3000
- **Database**: Neon PostgreSQL
