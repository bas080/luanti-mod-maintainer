use strict;
use warnings;
use Test::More;
use LWP::Simple;

my $file = "LICENSE.txt";
my $url  = "https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt";

# Fetch the LGPL 2.1 text
my $text = get($url);
ok($text, "Fetched LGPL 2.1 text") or BAIL_OUT("Failed to fetch $url");

# Write to LICENSE.txt
open my $fh, '>', $file or die "Cannot write to $file: $!";
print $fh $text;
close $fh;

pass("LICENSE.txt updated with LGPL 2.1");

done_testing();