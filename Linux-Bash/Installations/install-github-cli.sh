VERSION=`curl  "https://api.github.com/repos/cli/cli/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-`

echo $VERSION

curl -sSL https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.tar.gz -o gh_${VERSION}_linux_amd64.tar.gz

tar xvf gh_${VERSION}_linux_amd64.tar.gz

sudo cp gh_${VERSION}_linux_amd64/bin/gh /usr/local/bin/

gh version

sudo cp -r gh_${VERSION}_linux_amd64/share/man/man1/* /usr/share/man/man1/

man gh
# man gh-issue
# man gh-pr
