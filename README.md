# Luanti Mod Maintainer

When managing things that are similar; it's nice to have tools that automate and enforce rules which should improve consistency.

<!-- TOC -->

This repo manages the following repositories.

> $DIR is a environment variable that points to a (temporary) directory.
> This directory is used for cloning repos and running tests.

We use references to the git repository. This is more git provider agnostic.

```txt
git@github.com:bas080/mtpaint.git
git@github.com:bas080/pathogen.git
git@github.com:bas080/small_fall.git
git@github.com:bas080/trudged.git
git@github.com:bas080/massive_tree.git
git@github.com:bas080/vines.git
```

## Utility to iterate over repos and run code

Utilities are stored here.

```bash
mkdir -p util
```

```bash
#!/usr/bin/env bash


JUST RUN PROVE IN EACH REPO. CONSIDER PLACING THAT AT THE BOTTOM OF THIS FILE.
parent_dir="$1"

# read the script from stdin into a variable
script="$(cat)"

# iterate over subdirectories
```

## Fetching latest changes for repo

```bash
# Consider making this a manual step because it is expensive.
exit 0 #

mkdir -p "$DIR/repository"
cd "$DIR/repository"

while read -r repo; do
  git clone "$repo" || true
done < "$DIR/repositories.txt"

find -maxdepth 1 -type d | while read -r repo_dir; do
  (cd "$repo_dir" && git pull)
done
```

## Has a `.cdb.json` file

```bash
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
```

## content db uses the repo markdown for long description

Instead of having a massive string duplicated in my cdb json; I instead update the contentDB directly. 

Because we do not want to hit the contentDB every time we run tests we instead report on this and then have it be a manual step.

```bash
#/usr/bin/env bash

source bash-tap

# TODO: read the .cdb.json for required information.

diff <(cat README.md) <(curl -sL 'https://content.luanti.org/api/packages/bas080/small_fall/' | jq .long_description)
```

```bash
#!/usr/bin/env bash

curl "$CONTENTDB_ORIGIN/api/packages/<author>/<name>/" \
    -X PUT \
    -H "Authorization: Bearer $CONTENTDB_API_KEY" \
```

## Perform syntax check

```bash
#!/usr/bin/env bash

source bash-tap

luacheck  ./*.lua ./*/*.lua ./**/*.lua
success "Lua code passes luacheck"
```

## Run tests in each repository

```bash
export CURRENT_DIRECTORY="$PWD"

for dir in "$DIR"/repository/*/; do
    # remove trailing slash
    dir="${dir%/}"
    # run the script with the subdirectory as argument
	printf "\nTESTS FOR: %s\n" "$dir"
    (cd "$dir" && prove "$CURRENT_DIRECTORY/t" | npx tap-spec )
done
```
```

TESTS FOR: /tmp/luanti-mod-maintainer/repository/massive_tree
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t .......... 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 3/3 subtests 
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t .. 
    Dubious, test returned 255 (wstat 65280, 0xff00)
    No subtests run 
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t .................. 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/1 subtests 
    Test Summary Report
    -------------------
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t        (Wstat: 256 (exited 1) Tests: 3 Failed: 3)
      Failed tests:  1-3
      Non-zero exit status: 1
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t (Wstat: 65280 (exited 255) Tests: 0 Failed: 0)
      Non-zero exit status: 255
      Parse errors: No plan found in TAP output
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t                (Wstat: 256 (exited 1) Tests: 1 Failed: 1)
      Failed test:  1
      Non-zero exit status: 1
      Parse errors: No plan found in TAP output
    Files=3, Tests=4,  0 wallclock secs ( 0.02 usr  0.00 sys +  0.04 cusr  0.01 csys =  0.07 CPU)
    Result: FAIL



TESTS FOR: /tmp/luanti-mod-maintainer/repository/mtpaint
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t .......... ok
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t .. 
    Dubious, test returned 255 (wstat 65280, 0xff00)
    No subtests run 
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t .................. 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/1 subtests 
    Test Summary Report
    -------------------
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t (Wstat: 65280 (exited 255) Tests: 0 Failed: 0)
      Non-zero exit status: 255
      Parse errors: No plan found in TAP output
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t                (Wstat: 256 (exited 1) Tests: 1 Failed: 1)
      Failed test:  1
      Non-zero exit status: 1
      Parse errors: No plan found in TAP output
    Files=3, Tests=4,  0 wallclock secs ( 0.02 usr  0.00 sys +  0.06 cusr  0.02 csys =  0.10 CPU)
    Result: FAIL



TESTS FOR: /tmp/luanti-mod-maintainer/repository/pathogen
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t .......... 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 3/3 subtests 
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t .. 
    Dubious, test returned 255 (wstat 65280, 0xff00)
    No subtests run 
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t .................. 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/1 subtests 
    Test Summary Report
    -------------------
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t        (Wstat: 256 (exited 1) Tests: 3 Failed: 3)
      Failed tests:  1-3
      Non-zero exit status: 1
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t (Wstat: 65280 (exited 255) Tests: 0 Failed: 0)
      Non-zero exit status: 255
      Parse errors: No plan found in TAP output
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t                (Wstat: 256 (exited 1) Tests: 1 Failed: 1)
      Failed test:  1
      Non-zero exit status: 1
      Parse errors: No plan found in TAP output
    Files=3, Tests=4,  0 wallclock secs ( 0.01 usr  0.00 sys +  0.03 cusr  0.01 csys =  0.05 CPU)
    Result: FAIL



TESTS FOR: /tmp/luanti-mod-maintainer/repository/small_fall
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t .......... 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 3/3 subtests 
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t .. 
    Dubious, test returned 255 (wstat 65280, 0xff00)
    No subtests run 
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t .................. 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/1 subtests 
    Test Summary Report
    -------------------
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t        (Wstat: 256 (exited 1) Tests: 3 Failed: 3)
      Failed tests:  1-3
      Non-zero exit status: 1
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t (Wstat: 65280 (exited 255) Tests: 0 Failed: 0)
      Non-zero exit status: 255
      Parse errors: No plan found in TAP output
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t                (Wstat: 256 (exited 1) Tests: 1 Failed: 1)
      Failed test:  1
      Non-zero exit status: 1
      Parse errors: No plan found in TAP output
    Files=3, Tests=4,  0 wallclock secs ( 0.03 usr  0.00 sys +  0.04 cusr  0.00 csys =  0.07 CPU)
    Result: FAIL



TESTS FOR: /tmp/luanti-mod-maintainer/repository/trudged
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t .......... 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 3/3 subtests 
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t .. 
    Dubious, test returned 255 (wstat 65280, 0xff00)
    No subtests run 
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t .................. 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/1 subtests 
    Test Summary Report
    -------------------
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t        (Wstat: 256 (exited 1) Tests: 3 Failed: 3)
      Failed tests:  1-3
      Non-zero exit status: 1
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t (Wstat: 65280 (exited 255) Tests: 0 Failed: 0)
      Non-zero exit status: 255
      Parse errors: No plan found in TAP output
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t                (Wstat: 256 (exited 1) Tests: 1 Failed: 1)
      Failed test:  1
      Non-zero exit status: 1
      Parse errors: No plan found in TAP output
    Files=3, Tests=4,  0 wallclock secs ( 0.04 usr  0.00 sys +  0.04 cusr  0.01 csys =  0.09 CPU)
    Result: FAIL



TESTS FOR: /tmp/luanti-mod-maintainer/repository/vines
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t .......... 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/3 subtests 
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t .. 
    Dubious, test returned 255 (wstat 65280, 0xff00)
    No subtests run 
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t .................. 
    Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/1 subtests 
    Test Summary Report
    -------------------
    /home/blue/project/luanti-mod-maintainer/t/has-dot-cdb-json.t        (Wstat: 256 (exited 1) Tests: 3 Failed: 1)
      Failed test:  3
      Non-zero exit status: 1
    /home/blue/project/luanti-mod-maintainer/t/long_description_in_sync.t (Wstat: 65280 (exited 255) Tests: 0 Failed: 0)
      Non-zero exit status: 255
      Parse errors: No plan found in TAP output
    /home/blue/project/luanti-mod-maintainer/t/luacheck.t                (Wstat: 256 (exited 1) Tests: 1 Failed: 1)
      Failed test:  1
      Non-zero exit status: 1
      Parse errors: No plan found in TAP output
    Files=3, Tests=4,  0 wallclock secs ( 0.02 usr  0.00 sys +  0.06 cusr  0.01 csys =  0.09 CPU)
    Result: FAIL


```
