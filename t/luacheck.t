#!/usr/bin/env bash

source bash-tap

luacheck  ./*.lua ./*/*.lua ./**/*.lua
success "Lua code passes luacheck"
