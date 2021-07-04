git push

#python2 -m mkdocs gh-deploy -b master
#python3 -m mkdocs gh-deploy -b master

docker run --rm -it -v ~/.ssh:/root/.ssh -v ${PWD}:/docs squidfunk/mkdocs-material gh-deploy -b master
