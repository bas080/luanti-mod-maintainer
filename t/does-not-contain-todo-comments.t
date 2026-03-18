use strict;
use warnings;
use Test::More;
use File::Find;

my @blocked = (
    'CONSIDER',
    'TODO',
    'TBD',
    'FIXME',
    'XXX',
    'HACK',
    'BUG',
    'WIP',
    'REVIEW',
    'OPTIMIZE',
    'TEMP',
    'REMOVE ME',
    'NOT IMPLEMENTED',
);

my $pattern = join '|', map { quotemeta } @blocked;
$pattern = qr/\b($pattern)\b/i;

my @lua_files;

find(
    sub {
        return unless -f $_;
        return unless $_ =~ /\.lua$/;
        push @lua_files, $File::Find::name;
    },
    '.'
);

plan tests => scalar @lua_files;

for my $file (@lua_files) {
    open my $fh, '<', $file or die "Cannot open $file: $!";
    my $line_no = 0;
    my $found;

    while (my $line = <$fh>) {
        $line_no++;
        if ($line =~ $pattern) {
            diag("$file:$line_no: $line");
            $found = 1;
        }
    }

    close $fh;

    ok(!$found, "$file has no blocked markers");
}
