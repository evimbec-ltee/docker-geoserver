#/usr/bin/bash
ECR_REGISTRY=014233203916.dkr.ecr.ca-central-1.amazonaws.com
ECR_REPOSITORY=internal-images

docker-compose -f docker-compose-build.yml build

aws ecr get-login-password --region ca-central-1 | docker login --username AWS --password-stdin $ECR_REGISTRY/$ECR_REPOSITORY
source .env && docker tag kartoza/geoserver-mod:$GS_VERSION $ECR_REGISTRY/$ECR_REPOSITORY:kartoza-geoserver-mod_$GS_VERSION
source .env && docker push $ECR_REGISTRY/$ECR_REPOSITORY:kartoza-geoserver-mod_$GS_VERSION


