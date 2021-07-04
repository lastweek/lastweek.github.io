FROM squidfunk/mkdocs-material
RUN pip install --upgrade pip
RUN pip install pymdown-extensions
#RUN pip install mkdocs-pdf-export-plugin
RUN pip install mkdocs-git-revision-date-localized-plugin
RUN pip install mkdocs-gitbook
