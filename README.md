# CI/CD Pipeline for Laravel on Hostinger via SSH

This guide will help you set up a continuous integration and continuous deployment (CI/CD) pipeline to automatically deploy your Laravel application to Hostinger using SSH.

## Prerequisites

- A Laravel application in a Git repository (GitHub, GitLab, or Bitbucket)
- A Hostinger hosting account with SSH access enabled
- SSH credentials for your Hostinger account
- Basic familiarity with Git and command-line operations

## Pipeline Overview

We'll create a pipeline that:
1. Triggers when you push code to your repository
2. Runs tests to ensure your code is working properly
3. Builds your Laravel application
4. Deploys the application to your Hostinger hosting via SSH

## Setting Up GitHub Actions Pipeline

We'll use GitHub Actions for this example, but the concepts can be adapted for GitLab CI or Bitbucket Pipelines.

### Step 1: Create SSH Keys

First, generate an SSH key pair on your local machine:

```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com" -f ~/.ssh/hostinger_deploy
```

This creates:
- A private key at `~/.ssh/hostinger_deploy`
- A public key at `~/.ssh/hostinger_deploy.pub`

### Step 2: Add Public Key to Hostinger

1. Log in to your Hostinger account
2. Navigate to "SSH Access" or "SSH Keys" section
3. Add the content of your public key (`~/.ssh/hostinger_deploy.pub`)

### Step 3: Add Private Key to GitHub Repository Secrets

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Create the following secrets:
   - `SSH_PRIVATE_KEY`: The content of your private key file
   - `SSH_HOST`: Your Hostinger server hostname (e.g., `123.123.123.123`)
   - `SSH_USERNAME`: Your Hostinger SSH username
   - `SSH_PORT`: SSH port (usually `22`)
   - `REMOTE_DIR`: Your Laravel application directory on Hostinger (e.g., `/home/u123456789/public_html`)

### Step 4: Create GitHub Actions Workflow File

Create a file named `.github/workflows/deploy.yml` in your repository:

```yaml
name: Deploy Laravel to Hostinger

on:
  push:
    branches: [ main ]  # Change this to your main branch name

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'  # Change this to match your Laravel version requirements
          extensions: mbstring, xml, ctype, iconv, intl, pdo_mysql, bcmath, zip
          coverage: none
          
      - name: Install dependencies
        run: composer install --no-dev --optimize-autoloader --no-interaction

      - name: Create .env file
        run: |
          cp .env.example .env
          php artisan key:generate
          
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install & Build Frontend
        run: |
          npm install
          npm run build
          
      - name: Run tests
        run: vendor/bin/phpunit
        
      - name: Configure SSH
        run: |
          mkdir -p ~/.ssh/
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          ssh-keyscan -p ${{ secrets.SSH_PORT }} ${{ secrets.SSH_HOST }} >> ~/.ssh/known_hosts
          
      - name: Deploy to Hostinger
        run: |
          rsync -avz --delete \
            -e "ssh -i ~/.ssh/deploy_key -p ${{ secrets.SSH_PORT }}" \
            --exclude=".git/" \
            --exclude=".github/" \
            --exclude=".env" \
            --exclude="node_modules/" \
            --exclude="tests/" \
            ./ ${{ secrets.SSH_USERNAME }}@${{ secrets.SSH_HOST }}:${{ secrets.REMOTE_DIR }}
            
      - name: Post-deployment setup
        run: |
          ssh -i ~/.ssh/deploy_key -p ${{ secrets.SSH_PORT }} ${{ secrets.SSH_USERNAME }}@${{ secrets.SSH_HOST }} "cd ${{ secrets.REMOTE_DIR }} && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache"
```

## Setting Up GitLab CI Pipeline

If you're using GitLab instead of GitHub, here's a `.gitlab-ci.yml` file you can use:

```yaml
stages:
  - build
  - test
  - deploy

variables:
  PHP_VERSION: "8.2"

build:
  stage: build
  image: php:${PHP_VERSION}-cli
  script:
    - apt-get update -yqq
    - apt-get install -yqq git libzip-dev zip unzip libpng-dev
    - docker-php-ext-install zip gd pdo_mysql
    - curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    - composer install --no-dev --optimize-autoloader --no-interaction
  artifacts:
    paths:
      - vendor/
      - public/

test:
  stage: test
  image: php:${PHP_VERSION}-cli
  dependencies:
    - build
  script:
    - apt-get update -yqq
    - apt-get install -yqq git libzip-dev zip unzip libpng-dev
    - docker-php-ext-install zip gd pdo_mysql
    - vendor/bin/phpunit

deploy:
  stage: deploy
  image: alpine:latest
  dependencies:
    - build
  before_script:
    - apk add --no-cache openssh-client rsync
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
    - echo "$SSH_KNOWN_HOSTS" >> ~/.ssh/known_hosts
    - chmod 644 ~/.ssh/known_hosts
  script:
    - rsync -avz --delete 
      --exclude=".git/" 
      --exclude=".gitlab-ci.yml" 
      --exclude=".env" 
      --exclude="node_modules/" 
      --exclude="tests/" 
      ./ $SSH_USERNAME@$SSH_HOST:$REMOTE_DIR
    - ssh $SSH_USERNAME@$SSH_HOST "cd $REMOTE_DIR && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache"
  only:
    - main  # Change this to your main branch name
```

## Setting Up Bitbucket Pipelines

If you're using Bitbucket, here's a `bitbucket-pipelines.yml` file:

```yaml
image: php:8.2

pipelines:
  branches:
    main:  # Change this to your main branch name
      - step:
          name: Build and Test
          caches:
            - composer
          script:
            - apt-get update && apt-get install -y unzip git zip libzip-dev libpng-dev
            - docker-php-ext-install zip gd pdo_mysql
            - curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
            - composer install --no-dev --optimize-autoloader --no-interaction
            - vendor/bin/phpunit
          artifacts:
            - vendor/**
            - public/**
      - step:
          name: Deploy to Hostinger
          deployment: production
          script:
            - apt-get update && apt-get install -y openssh-client rsync
            - mkdir -p ~/.ssh
            - echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
            - chmod 600 ~/.ssh/id_rsa
            - ssh-keyscan -H $SSH_HOST >> ~/.ssh/known_hosts
            - rsync -avz --delete 
              --exclude=".git/" 
              --exclude="bitbucket-pipelines.yml" 
              --exclude=".env" 
              --exclude="node_modules/" 
              --exclude="tests/" 
              ./ $SSH_USERNAME@$SSH_HOST:$REMOTE_DIR
            - ssh $SSH_USERNAME@$SSH_HOST "cd $REMOTE_DIR && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache"
```

## Environment Variables and Secrets

For any of these CI solutions, you'll need to configure the following environment variables/secrets:

- `SSH_PRIVATE_KEY`: Your SSH private key
- `SSH_HOST`: Your Hostinger server hostname
- `SSH_USERNAME`: Your Hostinger SSH username 
- `SSH_PORT`: SSH port (usually 22)
- `REMOTE_DIR`: Your Laravel application directory on Hostinger

## Hostinger-Specific Considerations

### Laravel Environment Setup

1. Set up your `.env` file on the Hostinger server with your production settings:
   ```
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://your-domain.com
   
   DB_CONNECTION=mysql
   DB_HOST=your-hostinger-mysql-host
   DB_PORT=3306
   DB_DATABASE=your-database-name
   DB_USERNAME=your-database-username
   DB_PASSWORD=your-database-password
   ```

2. Configure filesystem permissions:
   ```bash
   chmod -R 755 /path/to/your/laravel/application
   chmod -R 777 /path/to/your/laravel/application/storage
   chmod -R 777 /path/to/your/laravel/application/bootstrap/cache
   ```

### Hostinger-Specific PHP Settings

You might need to create or modify `.htaccess` file in your project root to set PHP settings:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>

# PHP settings
<IfModule mod_php7.c>
    php_value upload_max_filesize 64M
    php_value post_max_size 64M
    php_value max_execution_time 300
    php_value max_input_time 300
</IfModule>
```

## Troubleshooting

### Common Issues and Solutions

1. **SSH Connection Issues**
   - Verify SSH access is enabled in your Hostinger control panel
   - Confirm your SSH key is properly added to Hostinger
   - Check if your SSH port is correct (usually 22, but might be different)

2. **Permission Issues**
   - Ensure your Laravel storage and bootstrap/cache directories are writable
   - Check file ownership on the server

3. **Database Migration Failures**
   - Verify your database credentials in the .env file
   - Ensure your database user has proper permissions

4. **Deployment Timeout**
   - For large applications, you might need to increase the timeout in your CI/CD configuration

## Advanced Configuration

### Automating Database Backups Before Deployment

Add this to your deployment script:

```bash
ssh $SSH_USERNAME@$SSH_HOST "cd $REMOTE_DIR && php artisan backup:run"
```

### Zero-Downtime Deployment

For a more advanced setup with zero-downtime deployment:

1. Deploy to a new directory
2. Run migrations and build assets
3. Create a symbolic link to the new deployment
4. Keep previous deployments for quick rollbacks

### Slack Notifications

Add notifications to your GitHub Actions workflow:

```yaml
- name: Notify Slack on success
  if: success()
  uses: rtCamp/action-slack-notify@v2
  env:
    SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
    SLACK_CHANNEL: deployments
    SLACK_TITLE: Successful Deployment
    SLACK_MESSAGE: 'Laravel app successfully deployed to Hostinger 🚀'
    SLACK_COLOR: good

- name: Notify Slack on failure
  if: failure()
  uses: rtCamp/action-slack-notify@v2
  env:
    SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
    SLACK_CHANNEL: deployments
    SLACK_TITLE: Failed Deployment
    SLACK_MESSAGE: 'Laravel app deployment to Hostinger failed ❌'
    SLACK_COLOR: danger
```

## Conclusion

You now have a complete CI/CD pipeline set up for your Laravel application on Hostinger. This pipeline will automatically build, test, and deploy your application whenever you push changes to your main branch.

Remember to adjust the configuration to match your specific requirements and Laravel version. If you encounter any issues, check the logs in your CI/CD platform and SSH access logs on your Hostinger server.