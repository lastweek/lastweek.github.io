git push

#python2 -m mkdocs gh-deploy -b master
mkdocs gh-deploy -b master

#docker run --rm -it -v ~/.ssh:/root/.ssh -v ${PWD}:/docs squidfunk/mkdocs-material:7.1.8 gh-deploy -b master
