#/usr/bin/env bash

source bash-tap

# TODO: read the .cdb.json for required information.

diff <(cat README.md) <(curl -sL 'https://content.luanti.org/api/packages/bas080/small_fall/' | jq .long_description)
