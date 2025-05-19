# Laravel Automated Deployment to Hostinger

![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)
![Laravel](https://img.shields.io/badge/Laravel-FF2D20?logo=laravel&logoColor=white)
![Hostinger](https://img.shields.io/badge/Hostinger-3066BE?logo=hostinger&logoColor=white)

Automated CI/CD pipeline for deploying Laravel applications to Hostinger using GitHub Actions.

## Table of Contents
- [🚀 Features](#-features)
- [📋 Prerequisites](#-prerequisites)
- [⚙️ Setup Guide](#️-setup-guide)
  - [🔑 SSH Key Setup](#-ssh-key-setup)
  - [🔐 GitHub Secrets Configuration](#-github-secrets-configuration)
- [🔄 Deployment Workflow](#-deployment-workflow)
- [👨‍💻 Manual Deployment](#-manual-deployment)
- [🐛 Troubleshooting](#-troubleshooting)
- [🔧 Maintenance](#-maintenance)

## 🚀 Features
- **Automatic deployments** on push to `master` branch
- **Secure SSH transfers** with encrypted connections
- **Optimized production builds** with cached routes and views
- **Zero-downtime deployment** strategy
- **Complete environment setup** including proper permissions
- **Two-phase deployment** (build + deploy) with artifact storage

## 📋 Prerequisites
Before starting, ensure you have:
- Hostinger hosting account with **SSH access enabled**
- GitHub repository for your Laravel project
- Laravel 9.x or 10.x application
- PHP 8.2 configured on Hostinger
- Composer 2.x installed

## ⚙️ Setup Guide

### 🔑 SSH Key Setup

#### 1. Generate SSH Key Pair
Run on your local machine:
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
Press Enter to accept default location (~/.ssh/id_rsa)

Enter a secure passphrase (recommended)

2. Configure Hostinger
Log in to Hostinger control panel

Navigate to Advanced → SSH Access

Click Manage SSH Keys

Add new key with contents of ~/.ssh/id_rsa.pub

3. Test Connection
bash
ssh -p 22 your_cpanel_username@yourdomain.com
🔐 GitHub Secrets Configuration
Navigate to:
Repository Settings → Secrets → Actions → New Repository Secret

Add these required secrets:

Secret Name	Example Value	Description
SSH_PRIVATE_KEY	Contents of id_rsa	Private SSH key
SSH_HOST	yourdomain.com	Your domain
SSH_USERNAME	u12345678	Hostinger username
SSH_PORT	22	SSH port
REMOTE_DIR	/home/u12345678/domains/example.com/public_html	Deployment path
🔄 Deployment Workflow
The system uses GitHub Actions with this flow:

Diagram
Code
graph TD
    A[Code Push] --> B{Is master branch?}
    B -->|Yes| C[Start Workflow]
    C --> D[Build Phase]
    D --> E[Deploy Phase]
    E --> F[Verify]
    B -->|No| G[Do nothing]
Build Phase Includes:

PHP 8.2 environment setup

Composer dependency installation

Environment configuration

Production optimizations

Artifact creation

Deploy Phase Includes:

Secure file transfer via SCP

Automatic extraction on server

Permission configuration

Laravel optimization commands:

bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
👨‍💻 Manual Deployment
If automated deployment fails:

Prepare Build Locally

bash
composer install --no-dev --optimize-autoloader
cp .env.example .env
php artisan key:generate
Upload Files

bash
scp -P 22 -r * user@hostinger.com:public_html/
Server-Side Setup

bash
chmod -R 775 storage bootstrap/cache
php artisan storage:link
🐛 Troubleshooting
Common Issues
Error	Solution
Permission denied	Verify SSH key and server permissions
Missing .env	Ensure file exists with correct values
White screen	Check storage permissions and error logs
Deployment fails	Examine GitHub Actions logs
Debugging SSH
bash
ssh -vvv -p 22 user@hostinger.com
Checking Logs
bash
# On server
tail -f storage/logs/laravel.log
🔧 Maintenance
Updating Deployment
Edit .github/workflows/deploy.yml

Commit changes to master

Monitor Actions tab for results

Key Rotation
Generate new keys:

bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/new_deploy_key
Update both Hostinger and GitHub secrets

Monitoring
GitHub Actions: View workflow runs

Hostinger: Check File Manager and logs

Laravel: Monitor storage/logs

Security Note: Never commit sensitive files (.env, .htaccess) to your repository. The deployment workflow handles these automatically.

Deploy to Hostinger


This README includes:

1. **Visual Enhancements**:
   - Colorful badges and emojis for better scanning
   - Mermaid diagram for workflow visualization
   - Clean tables for organized information

2. **Complete Documentation**:
   - End-to-end setup instructions
   - Both automated and manual deployment methods
   - Comprehensive troubleshooting guide
   - Maintenance best practices

3. **Technical Details**:
   - Exact commands for each step
   - Configuration requirements
   - Security considerations

4. **User-Friendly Features**:
   - Clear section headers
   - Consistent formatting
   - Actionable items
   - Visual cues

The document is ready to use - just copy this into your project's `README.md` file and it will provide complete deployment documentation for your team.
