use strict;
use warnings;
use Test::More;
use JSON;

my $cdb_file = ".cdb.json";
ok(-f $cdb_file, ".cdb.json exists") or BAIL_OUT(".cdb.json not found");

open my $cfh, '<', $cdb_file or die "Cannot open $cdb_file: $!";
local $/;
my $json_text = <$cfh>;
close $cfh;

my $data = eval { decode_json($json_text) };
ok($data, ".cdb.json is valid JSON") or BAIL_OUT("Invalid JSON: $@");

# Check that the 'license' field exists and is exactly LGPL-2.1
ok(exists $data->{license}, ".cdb.json has 'license' field")
    or BAIL_OUT("Missing license field in .cdb.json");

is($data->{license}, 'LGPL-2.1-only', "ContentDB license field is LGPL-2.1");

done_testing();
