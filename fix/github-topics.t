#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use JSON;

# 1. Load .cdb.json
ok(-f ".cdb.json", ".cdb.json exists") or BAIL_OUT(".cdb.json not found");

open my $cfh, '<', '.cdb.json' or die "Cannot open .cdb.json: $!";
local $/;
my $json_text = <$cfh>;
close $cfh;

my $cdb_data = eval { decode_json($json_text) };
ok($cdb_data, ".cdb.json is valid JSON") or BAIL_OUT("Invalid JSON: $@");

my $author = $cdb_data->{'$author'};
my $mod    = $cdb_data->{name};

ok($author, ".cdb.json has '\$author' field") or BAIL_OUT("Missing \$author in .cdb.json");
ok($mod,    ".cdb.json has 'name' field")   or BAIL_OUT("Missing name in .cdb.json");

# 2. Fetch topics using higher-level gh command
my $topics_str = `gh repo view $author/$mod --json topics --jq '.topics | join(",")' 2>&1`;
ok(defined $topics_str, "Fetched topics using gh repo view") or BAIL_OUT("Failed to fetch topics: $topics_str");

chomp($topics_str);
my @topics = split /,/, $topics_str;

# 3. Check if 'luanti-mod' topic exists
my $has_topic = grep { $_ eq 'luanti-mod' } @topics;

if ($has_topic) {
    pass("'luanti-mod' topic already present");
} else {
    diag("'luanti-mod' topic missing, adding now...");
    my $ret = system('gh', 'repo', 'edit', "$author/$mod", '--add-topic', 'luanti-mod');

    if ($ret == 0) {
        pass("'luanti-mod' topic added successfully");
    } else {
        fail("Failed to add 'luanti-mod' topic (exit code $ret)");
    }
}

done_testing();