use strict;
use warnings;
use Test::More;
use JSON;
use LWP::Simple;

# 1. Check README.md exists
ok(-f "README.md", "README.md exists") or BAIL_OUT("README.md not found");

# 2. Load local README and normalize line endings
open my $fh, '<', 'README.md' or die "Cannot open README.md: $!";
local $/;
my $local_readme = <$fh>;
close $fh;
$local_readme =~ s/\r\n?/\n/g;        # normalize CRLF -> LF
$local_readme =~ s/\s+$//mg;          # trim trailing whitespace on each line

# 3. Load .cdb.json
ok(-f ".cdb.json", ".cdb.json exists") or BAIL_OUT(".cdb.json not found");

open my $cfh, '<', '.cdb.json' or die "Cannot open .cdb.json: $!";
local $/;
my $json_text = <$cfh>;
close $cfh;

my $cdb_data = eval { decode_json($json_text) };
ok($cdb_data, ".cdb.json is valid JSON") or BAIL_OUT("Invalid JSON: $@");

# 4. Ensure name exists
my $mod_name = $cdb_data->{name} // '';
ok($mod_name, ".cdb.json has a 'name' field") or BAIL_OUT("Missing name in .cdb.json");

# 5. Fetch remote long_description from ContentDB
my $url = "https://content.luanti.org/api/packages/bas080/$mod_name/";
my $json = get($url);
ok($json, "Fetched ContentDB package info") or BAIL_OUT("Failed to fetch $url");

my $remote_data = eval { decode_json($json) };
ok($remote_data, "ContentDB JSON is valid") or BAIL_OUT("Invalid JSON from ContentDB");

my $remote_desc = $remote_data->{long_description} // '';
ok($remote_desc, "Remote package has long_description");

# 6. Normalize remote description
$remote_desc =~ s/\r\n?/\n/g;
$remote_desc =~ s/\s+$//mg;

# 7. Compare local README.md with ContentDB long_description
is($local_readme, $remote_desc, "README.md matches ContentDB long_description");

done_testing();