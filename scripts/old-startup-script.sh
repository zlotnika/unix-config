gitlab-runner register --non-interactive --url https://gitlab.com/ --registration-token fheSopgnmD7M2Y7-RQQr --name gclinux-shell-bazel --tag-list shell,bazel,gcloud,v023 --cache-cache-shared --executor shell

gitlab-runner register --non-interactive --url https://gitlab.com/ --registration-token fheSopgnmD7M2Y7-RQQr --name gclinux-docker --non-interactive --tag-list docker,v023 --cache-cache-shared  --executor docker  --docker-image ubuntu:16.04  --docker-volumes /cache  --docker-pull-policy if-not-present  --docker-privileged  --docker-shm-size 0
