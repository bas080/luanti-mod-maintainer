#!/usr/bin/env bash

source bash-tap

plan 3

test -f '.cdb.json'
success "File exists"

jq < .cdb.json | diagnostics
success "And has valid json"

jq -e '
  (has("type") and has("title") and has("short_description"))
  or
  (error("Missing required field"))
' .cdb.json
success "Has required fields"
