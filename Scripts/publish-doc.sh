#!/bin/bash
set -e

jazzy

if [ -d "~/.observable-kit-documentation/" ]; then rm -rf ~/.observable-kit-documentation/; fi

mkdir -p ~/.observable-kit-documentation/ && rsync -r --exclude '.git' ./Documentation/ ~/.observable-kit-documentation/

git checkout gh-pages
git rm -rf .
git clean -fxd

cp -r ~/.observable-kit-documentation/ .

rm -rf ~/.observable-kit-documentation/

git commit -m "Publish documentation"
git push origin gh-pages
git checkout master