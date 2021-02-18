#!/bin/bash

# pipe everything to files
echo "Redirecting output to /startup-log..."

exec > /startup-log
exec 2>&1

mkdir -p /etc/gitlab-runner

function until-success() {
  "$@"
  while [ $? -ne 0 ]; do
    retrying "$@"...
    "$@"
  done
}

function unregister-all-runners() {
  docker run --rm \
         -v /etc/gitlab-runner:/etc/gitlab-runner \
         -v /var/run/docker.sock:/var/run/docker.sock \
         -e DOCKER_IMAGE=docker:latest \
         gitlab/gitlab-runner:v13.4.0 \
         unregister --all-runners
}

function register-shell-runner() {
  if grep -q ${HOSTNAME}-shell /etc/gitlab-runner/config.toml; then
    echo "Shell runner already instantiated..."
    return 0
  fi

  gitlab-runner register \
                --name ${HOSTNAME}-shell \
                --url https://gitlab.com/ \
                --registration-token bar \
                --tag-list shell,bazel,gcloud,v023 \
                --executor shell \
                --cache-cache-shared \
                --non-interactive

  grep -q ${HOSTNAME}-shell /etc/gitlab-runner/config.toml
  return $?
}

function register-flat-runner() {
  if grep -q ${HOSTNAME}-flat /etc/gitlab-runner/config.toml; then
    echo "Flat runner already instantiated..."
    return 0
  fi

  docker run --rm \
         -v /etc/gitlab-runner:/etc/gitlab-runner \
         -v /var/run/docker.sock:/var/run/docker.sock \
         -e DOCKER_IMAGE=docker:latest \
         gitlab/gitlab-runner:v13.4.0 \
         register --non-interactive \
         --name ${HOSTNAME}-flat \
         --url https://gitlab.com/ \
         --registration-token foo \
         --tag-list flat \
         --executor docker \
         --env DOCKER_SOCKET=/var/run/docker.sock \
         --env DOCKER_HOST= \
         --docker-tlsverify=false \
         --docker-privileged=false \
         --docker-disable-entrypoint-overwrite=false          \
         --docker-oom-kill-disable=false                      \
         --docker-volumes="/var/run/docker.sock:/var/run/docker.sock:ro" \
         --docker-cache-dir "/cache"

  grep -q ${HOSTNAME}-flat /etc/gitlab-runner/config.toml
  return $?
}

function register-normal-runner() {
  if grep -q ${HOSTNAME}-normal /etc/gitlab-runner/config.toml; then
    echo "Normal runner already instantiated..."
    return 0
  fi

  docker run --rm \
         -v /etc/gitlab-runner:/etc/gitlab-runner \
         -v /var/run/docker.sock:/var/run/docker.sock \
         -e DOCKER_IMAGE=docker:latest \
         gitlab/gitlab-runner:v13.4.0 \
         register --run-untagged -n \
         -u https://gitlab.com/ \
         -r foo \
         --docker-privileged \
         --name ${HOSTNAME}-normal \
         --env DOCKER_HOST=docker:2376 \
         --env DOCKER_TLS=true \
         --env DOCKER_CERT_PATH=/certs/client \
         --executor docker \
         --docker-image "docker:latest" \
         --docker-privileged \
         --docker-volumes "/certs/client"

  grep -q ${HOSTNAME}-normal /etc/gitlab-runner/config.toml
}

#until-success register-flat-runner
#until-success register-normal-runner
until-success register-shell-runner

if ( docker inspect gitlab-runner  2>/dev/null > /dev/null )
then
  echo "Restarting gitlab-runner."
  docker restart gitlab-runner
else
  echo "Starting gitlab-runner"
  # register:
  docker run -d --name gitlab-runner --restart always \
         -v /etc/gitlab-runner:/etc/gitlab-runner \
         -v /var/run/docker.sock:/var/run/docker.sock \
         gitlab/gitlab-runner:v13.4.0
fi

exit 0
