#!/bin/sh
set -e

VERSION=$(git name-rev --name-only --tags HEAD)
if [ "$VERSION" = "undefined" ]; then
  VERSION="$(git describe --tags | sed 's/-g/-/')-SNAPSHOT"
fi
docker build --pull --rm -t r.bennuoc.com/sd/geoip-nginx:"$VERSION" .
docker push r.bennuoc.com/sd/geoip-nginx:"$VERSION"
