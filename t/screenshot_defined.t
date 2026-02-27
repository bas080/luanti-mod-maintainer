use strict;
use warnings;
use Test::More;

my $file = "screenshot.png";

ok(-f $file, "screenshot.png exists in the mod root");

done_testing();