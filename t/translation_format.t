use strict;
use warnings;
use Test::More;

# Find all .tr and .po files
my @tr_files = glob("locale/*.tr");
my @po_files = glob("locale/*.po");

# Fail if any .tr files exist
for my $f (@tr_files) {
    fail(".tr file found: $f — please convert to .po");
}

# Fail if no .po files found
if (!@po_files) {
    fail("No .po translation files found — add at least one .po file in locale/");
} else {
    pass("Found .po translation files");

    # Check each .po file for basic formatting
    for my $file (@po_files) {
        eval {
            open my $fh, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!";
            my $first_line = <$fh>;
            chomp $first_line;
            ok($first_line eq 'msgid ""', "$file starts with msgid header");

            while (my $line = <$fh>) {
                chomp $line;
                # Allow empty lines or lines starting with msgid/msgstr or quotes
                ok($line =~ /^\s*$/ || $line =~ /^(msgid|msgstr|")/, "$file: line looks valid");
            }
            close $fh;
        };
        if ($@) {
            fail("Error reading $file: $@");
        }
    }
}

done_testing();