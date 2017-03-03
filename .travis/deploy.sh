#!/bin/sh

set -e

if [ ! -d "$HOME/.ssh" ]; then
    mkdir "$HOME/.ssh"
fi

mv "$TRAVIS_BUILD_DIR/.travis/deploy-key" "$HOME/.ssh/id_rsa"
chmod 600 "$HOME/.ssh/id_rsa"

rsync -e ssh -azz --delete "$TRAVIS_BUILD_DIR/_site/"* "$RUSER@$RHOST:$RLOCATION"
git clean -fdx
