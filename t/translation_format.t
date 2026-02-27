use strict;
use warnings;
use Test::More;

# Find all .tr files
my @tr_files = glob("locale/*.tr");
my @po_files = glob("locale/*.po");

# Fail if any .tr files exist
for my $f (@tr_files) {
    fail(".tr file found: $f — please convert to .po");
}

# Optional: warn if no .po files found
if (!@po_files) {
    fail("No .po translation files found — add at least one .po file in locale/");
} else {
    pass("Found .po translation files");
}

done_testing();