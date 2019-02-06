#!/bin/bash

echo "Update YUM"
sudo yum -y update

echo "Install Docker"
sudo yum install -y docker

echo "Start Docker"
sudo service docker start

echo "Login to ECR (your Docker Registry)"
$(aws ecr get-login --no-include-email --region eu-central-1)

echo "Start docker container"
docker run \
  -p 80:80 \
  --env "MONGO_DSN=${mongodb_dsn}" \
  --env "MONGO_DB=app" \
  ${docker_img_url}
