# Function to validate required secrets
validate_secrets() {
    if [ -z "$SSH_PRIVATE_KEY" ]; then
        echo "SSH_PRIVATE_KEY secret is missing"
        exit 1
    fi
    if [ -z "$SSH_HOST" ]; then
        echo "SSH_HOST secret is missing"
        exit 1
    fi
    if [ -z "$SSH_USERNAME" ]; then
        echo "SSH_USERNAME secret is missing"
        exit 1
    fi
    if [ -z "$SSH_PORT" ]; then
        echo "SSH_PORT secret is missing"
        exit 1
    fi
    if [ -z "$REMOTE_DIR" ]; then
        echo "REMOTE_DIR secret is missing"
        exit 1
    fi
}

# Function to install composer dependencies
install_composer() {
    composer install --no-dev --optimize-autoloader --no-interaction
}

# Function to setup environment
setup_environment() {
    cp .env.example .env
    php artisan key:generate
    sed -i 's/APP_ENV=local/APP_ENV=production/g' .env
    sed -i 's/APP_DEBUG=true/APP_DEBUG=false/g' .env
}

# Function to prepare deployment files
prepare_deployment() {
    # Create deployment directory
    mkdir -p deployment

    # Create .htaccess file in root
    echo '<IfModule mod_rewrite.c>
      RewriteEngine On
      RewriteCond %{REQUEST_URI} !^/public/
      RewriteRule ^(.*)$ /public/$1 [L,QSA]
  </IfModule>' >deployment/.htaccess

    # Copy all files
    cp -r * .env deployment/ || true

    # Fix index.php paths if needed
    if [ -f deployment/public/index.php ]; then
        sed -i "s|require __DIR__.'/../vendor/autoload.php'|require __DIR__.'/../vendor/autoload.php'|g" deployment/public/index.php
        sed -i "s|\$app = require_once __DIR__.'/../bootstrap/app.php'|\$app = require_once __DIR__.'/../bootstrap/app.php'|g" deployment/public/index.php
    fi

    # Set permissions
    chmod -R 777 deployment/storage
    chmod -R 777 deployment/bootstrap/cache
}

# Function to create the deployment package
create_package() {
    cd deployment
    zip -r ../laravel-deployment.zip .
}

# Function to configure SSH
configure_ssh() {
    mkdir -p ~/.ssh/
    echo "$SSH_PRIVATE_KEY" >~/.ssh/deploy_key
    chmod 600 ~/.ssh/deploy_key
    ssh-keyscan -p $SSH_PORT $SSH_HOST >>~/.ssh/known_hosts
}

# Function to deploy to Hostinger
deploy() {
    # Upload package
    scp -i ~/.ssh/deploy_key -P $SSH_PORT laravel-deployment.zip $SSH_USERNAME@$SSH_HOST:$REMOTE_DIR/

    # Extract and setup on server
    ssh -i ~/.ssh/deploy_key -p $SSH_PORT $SSH_USERNAME@$SSH_HOST "\
    cd $REMOTE_DIR && \
    unzip -o laravel-deployment.zip && \
    rm laravel-deployment.zip && \
    chmod -R 755 . && \
    chmod -R 777 storage bootstrap/cache && \
    php artisan migrate --force && \
    php artisan storage:link && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache"

    # Cleanup local files
    rm laravel-deployment.zip
}

# Function to verify deployment
verify_deployment() {
    # Add a curl command to verify the deployment if you have a public URL
    # curl -I https://test.codelus.io
    echo "Deployment completed successfully"
}

# Main execution
case "$1" in
validate_secrets)
    validate_secrets
    ;;
install_composer)
    install_composer
    ;;
setup_environment)
    setup_environment
    ;;
prepare_deployment)
    prepare_deployment
    ;;
create_package)
    create_package
    ;;
configure_ssh)
    configure_ssh
    ;;
deploy)
    deploy
    ;;
verify_deployment)
    verify_deployment
    ;;
*)
    echo "Usage: $0 {validate_secrets|install_composer|setup_environment|prepare_deployment|create_package|configure_ssh|deploy|verify_deployment}"
    exit 1
    ;;
esac

exit 0
