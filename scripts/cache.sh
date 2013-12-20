#!/bin/bash

set -e

DIR="$( cd "$( dirname "$0" )" && pwd )"
CACHEDIR="$DIR/../files/cache"

DLFILES=(
  "github.com/mozilla-services/heka/releases/download/v0.4.2/heka_0.4.2_amd64.deb"
  )

for DLFILE in ${DLFILES[@]};
  do
    wget -P $CACHEDIR -p -c --no-check-certificate https://$DLFILE
  done;