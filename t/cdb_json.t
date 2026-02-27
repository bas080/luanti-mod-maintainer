use strict;
use warnings;
use Test::More;
use JSON;

my $file = ".cdb.json";
ok(-f $file, ".cdb.json exists") or BAIL_OUT(".cdb.json not found");

open my $fh, '<', $file or die "Cannot open $file: $!";
local $/;
my $json_text = <$fh>;
close $fh;

my $data = eval { decode_json($json_text) };
ok($data, ".cdb.json is valid JSON") or BAIL_OUT("Invalid JSON: $@");

# Required fields
my @required = qw(type name title short_description dev_state license);

my @missing;
for my $key (@required) {
    push @missing, $key unless exists $data->{$key} && defined $data->{$key} && $data->{$key} ne '';
}

ok(!@missing, "All required fields exist")
    or diag("Missing required fields: " . join(", ", @missing));

# Validate 'type'
if (exists $data->{type}) {
    ok($data->{type} =~ /^(MOD|GAME|TXP)$/, "type has valid value")
        or diag("type should be one of MOD, GAME, TXP");
}

# Validate 'dev_state'
if (exists $data->{dev_state}) {
    ok($data->{dev_state} =~ /^(WIP|BETA|ACTIVELY_DEVELOPED|MAINTENANCE_ONLY|AS_IS|DEPRECATED|LOOKING_FOR_MAINTAINER)$/,
       "dev_state has valid value")
        or diag("dev_state should be one of WIP, BETA, ACTIVELY_DEVELOPED, MAINTENANCE_ONLY, AS_IS, DEPRECATED, LOOKING_FOR_MAINTAINER");
}

# Validate 'license' non-empty
if (exists $data->{license}) {
    ok(length $data->{license}, "license field is non-empty");
}

done_testing();
