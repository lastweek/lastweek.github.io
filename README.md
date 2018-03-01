# Software

- mkdocs
    - mkdocs server
    - mkdocs gh-deploy -b <branch>

# Contribute

The `master` branch contains HTML files generated and deployed by `mkdocs`, please do not push any contents directly to master branch. Current main development branch is `dev`, which has all the Markdown documents. If you want to add extra documents, please checkout current HEAD of `dev`, and then send a pull request to me, I will help to deploy them.

# My workflow

- `dev`: add or modify documents
- `dev`: use `mkdocs serve` to check the format
- `dev`: if everthing looks good, use `mkdocs gh-pages -b master` to deploy generated HTML files to master
- `master`: check contents (normally directly check website)
