.PHONY: nonprod_build prod_build

# Get the environment from the (first) target
first_target := $(word 1, $(MAKECMDGOALS))
first_target_tuple := $(subst _, , $(first_target))
TARGET_ENV := $(shell echo $(word 1, $(first_target_tuple)) | tr '[:lower:]' '[:upper:]')
OP := $(shell echo $(word 2, $(first_target_tuple)) | tr '[:lower:]' '[:upper:]')
$(info Environnment: $(TARGET_ENV), Operation: $(OP))

NONPROD_AWS_ACCOUNT=014233203916
PROD_AWS_ACCOUNT=673574581645
AWS_ACCOUNT = $($(TARGET_ENV)_AWS_ACCOUNT)
ECR_REPO=$(AWS_ACCOUNT).dkr.ecr.ca-central-1.amazonaws.com/internal-images
DEFAULT_DEV_AWS_PROFILE = geocentralis_non_prod_sso
DEFAULT_STAGE_AWS_PROFILE = geocentralis_non_prod_sso

DEFAULT_NONPROD_AWS_PROFILE = geocentralis_non_prod_sso
DEFAULT_PROD_AWS_PROFILE = geocentralis_prod_sso
AWS_PROFILE ?= $(DEFAULT_$(TARGET_ENV)_AWS_PROFILE)

aws_sso_login:
	sh -c "env AWS_PROFILE=$(AWS_PROFILE) aws sts get-caller-identity >/dev/null 2>&1" ; \
	if [ $$? != 0 ]; then \
		echo "session expired .... you need login again " ; \
		env AWS_PROFILE=$(AWS_PROFILE) aws sso login ; \
	fi

aws_sso_logout:
	env AWS_PROFILE=$(AWS_PROFILE) aws sso login --no-browser

aws_ecr_login: aws_sso_login
	env AWS_PROFILE=$(AWS_PROFILE) aws ecr get-login-password --region ca-central-1 | docker login --username AWS --password-stdin $(AWS_ACCOUNT).dkr.ecr.ca-central-1.amazonaws.com

build_image: aws_ecr_login
	docker-compose -f docker-compose-build.yml build
	eval $(shell shdotenv export GS_VERSION) && docker tag kartoza/geoserver-mod:$$GS_VERSION $(ECR_REPO):kartoza-geoserver-mod_$$GS_VERSION
	eval $(shell shdotenv export GS_VERSION) && docker push $(ECR_REPO):kartoza-geoserver-mod_$$GS_VERSION

nonprod_build: build_image

prod_build: build_image