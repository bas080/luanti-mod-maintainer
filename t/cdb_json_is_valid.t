use strict;
use warnings;
use Test::More;
use JSON qw(decode_json);
use JSON::Validator;

# ----- Load .cdb.json -----
my $cdb_file = ".cdb.json";
ok(-f $cdb_file, ".cdb.json exists") or BAIL_OUT(".cdb.json not found");

open my $fh, '<', $cdb_file or BAIL_OUT("Cannot open $cdb_file: $!");
local $/;
my $cdb_text = <$fh>;
close $fh;

my $cdb_data;
eval {
    $cdb_data = decode_json($cdb_text);
    1;
} or BAIL_OUT("Invalid JSON in .cdb.json: $@");

ok(ref $cdb_data eq 'HASH', ".cdb.json decoded successfully");

# ----- Load ContentDB JSON Schema -----
my $schema_url = $cdb_data->{"\$schema"}
    // 'https://content.luanti.org/api/cdb_schema/';

my $validator = JSON::Validator->new;

# Explicitly load remote schema
$validator->schema({ '$ref' => $schema_url });

# ----- Perform validation -----
my @errors = $validator->validate($cdb_data);

if (@errors) {
    diag("JSON schema validation errors:");
    diag($_->message . " at " . $_->path) for @errors;
    fail(".cdb.json does NOT conform to ContentDB schema");
} else {
    pass(".cdb.json conforms to ContentDB JSON Schema");
}

done_testing();