use strict;
use warnings;
use Test::More;
use File::Find;

my @files;

find(
    sub {
        return if -d && $_ eq '.git';
        return unless -f;
        return unless /\.lua$/;
        push @files, $File::Find::name;
    },
    '.'
);

ok(@files, "Found Lua files") or done_testing();

my @violations;

# Disallowed Luanti logging APIs
my @log_patterns = (
    [ qr/\bcore\.log\s*\(/,        'core.log() is not allowed' ],
    [ qr/\bminetest\.log\s*\(/,    'minetest.log() is not allowed' ],
    [ qr/\bcore\.debug\s*\(/,      'core.debug() is not allowed' ],
    [ qr/\bminetest\.debug\s*\(/,  'minetest.debug() is not allowed' ],
);

for my $file (@files) {

    open my $fh, '<', $file or die "Cannot open $file: $!";
    my @lines = <$fh>;
    close $fh;

    for my $i (0 .. $#lines) {
        my $line = $lines[$i];

        # Ignore full-line Lua comments
        next if $line =~ /^\s*--/;

        for my $entry (@log_patterns) {
            my ($pattern, $message) = @$entry;

            if ($line =~ $pattern) {
                push @violations,
                    "$file line " . ($i + 1) . ": $message";
            }
        }
    }
}

ok(!@violations, "No Luanti logging API usage found")
    or diag(join "\n", @violations);

done_testing();