# Magento 2

## Description
Magento 2 is a powerful, open-source e-commerce platform offering flexibility, scalability, and robust features for managing products, payments, shipping, and marketing across single or multiple online stores.

## magento commands
```sh

```

## Debug
view exception logs
```sh
cat var/log/exception.log 
```

regenerate files
```sh
php bin/magento setup:di:compile
php bin/magento setup:static-content:deploy -f
```

```sh
php bin/magento maintenance:disable
```

## Configuration
Located in directory: /app/etc/env.php

## Docker
 Be sure to set the $PROJECT_ID
```sh
export PROJECT_ID=$(gcloud config get-value project)
```

Below are some examples of *docker build* commands.

### List Docker Builds
```sh
gcloud artifacts docker images list us-east4-docker.pkg.dev/$PROJECT_ID/uequations-docker-registry/drupal --include-tags
```

#### Docker Build
```sh
docker build -t us-east4-docker.pkg.dev/$PROJECT_ID/uequations-docker-registry/magento2:v1 .
```
#### Push Docker Build to Registry
```sh
docker push us-east4-docker.pkg.dev/$PROJECT_ID/uequations-docker-registry/drupal:v1.9-ubuntu-apache-httpd
```

### Running the Docker Image Locally
```sh
docker run -e DB_HOST=... -e DB_PASSWORD=... -it -p 8080:80 us-east4-docker.pkg.dev/$PROJECT_ID/uequations-docker-registry/magento2:v1.2-breeze-theme
```

### Log in to interactive shell
```sh
docker ps
docker exec -it container_id_or_name /bin/bash
```

view exception logs
```sh
cat var/log/exception.log
```

## Remove
composer remove swissup/breeze-evolution


## Refernces
- https://commercemarketplace.adobe.com/swissup-breeze-evolution.html
- https://commercemarketplace.adobe.com/media/catalog/product/swissup-breeze-evolution-2-5-0-ece/installation_guides.pdf
- https://magento.stackexchange.com/questions/344418/m2-4-exception-throwing-while-executing-composer-require-higher-matching-versio
- https://breezefront.com/docs/installation