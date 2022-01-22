#!/bin/sh

dirname=github-backup-$(date "+%Y-%m-%d-%H-%M-%S")
mkdir "$dirname"
cd $dirname

#change these vars:
privateToken=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
userName=jimbrig

curl -H "Accept: application/vnd.github.nebula-preview+json" \
    -H "Authorization: token $privateToken" \
    "https://api.github.com/user/repos?visibility=all&affiliation=owner&per_page=200" \
    | jq -r '.[] | .name' \
    | while IFS= read projectName; do
        curl -H "Authorization: token $privateToken" -H "Accept: application/vnd.github.v3.raw" -L \
         "https://api.github.com/repos/$userName/$projectName/zipball" --output $projectName.zip
     done

echo Done! All files downloaded here: $(pwd)
