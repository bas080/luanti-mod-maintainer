#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use JSON;

# 1. Load .cdb.json to get author and mod
ok(-f ".cdb.json", ".cdb.json exists") or BAIL_OUT(".cdb.json not found");

open my $cfh, '<', '.cdb.json' or die "Cannot open .cdb.json: $!";
local $/;
my $json_text = <$cfh>;
close $cfh;

my $cdb_data = eval { decode_json($json_text) };
ok($cdb_data, ".cdb.json is valid JSON") or BAIL_OUT("Invalid JSON: $@");

my $author = $cdb_data->{'$author'} // '';
my $mod    = $cdb_data->{name}   // '';

ok($author, ".cdb.json has 'author' field") or BAIL_OUT("Missing author in .cdb.json");
ok($mod,    ".cdb.json has 'name' field")   or BAIL_OUT("Missing name in .cdb.json");

# 2. Fetch GitHub topics using gh CLI
my $json = `gh api repos/$author/$mod/topics -H "Accept: application/vnd.github.mercy-preview+json" 2>/dev/null`;
ok($json && $json =~ /\S/, "Fetched topics from GitHub") or BAIL_OUT("Failed to fetch topics for $author/$mod");

my $data = eval { decode_json($json) };
ok($data, "GitHub topics JSON is valid") or BAIL_OUT("Invalid JSON from GitHub: $@");

# 3. Check if 'luanti-mod' topic is present
my $topics = $data->{names} || [];
ok(@$topics, "Repo has topics");
like(join(',', @$topics), qr/\bluanti-mod\b/, "Repo has 'luanti-mod' topic");

done_testing();
