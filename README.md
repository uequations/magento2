# Magento 2

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
docker run -it -p 8080:80 us-east4-docker.pkg.dev/$PROJECT_ID/uequations-docker-registry/ubuntu-apache-httpd-drupal-4614:v4
```

### Log in to interactive shell
```sh
docker ps
docker exec -it container_id_or_name /bin/bash
```