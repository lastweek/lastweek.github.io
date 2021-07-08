# Yizhou Shan's Home Page

## Deploy

Method 1: Install all tools.
```
./install.sh
mkdocs serve
mkdocs gh-deploy -b master
```

Method 2: Use docker.
```
# We have a Dockerfile
./build_docker.sh
docker run --rm -it -v ~/.ssh:/root/.ssh -v ${PWD}:/docs squidfunk/mkdocs-material:7.1.8 gh-deploy -b master
```
