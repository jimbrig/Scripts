#!/bin/bash

git config --global pull.rebase false
git config --global user.name "Jimmy Briggs"
git config --global user.email "jimbrig1993@outlook.com"
git config --global user.signingKey "55DBBA521DCA7102EEEECC53D4B3C297488AAB3F"
git config --global default.protocol "ssh"
git config --global core.editor "code-insiders --wait --new-window"
git config --global core.longpaths "true"
git config --global core.excludesfile "~/.gitignore"
git config --global core.attributesfile "~/.gitattributes"
git config --global core.autocrlf "true"
git config --global core.symlinks "true"
git config --global core.safecrlf "warn"
git config --global core.untrackedCache "true"

git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=31536000'