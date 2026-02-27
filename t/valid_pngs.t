use strict;
use warnings;
use Test::More;

my @files = glob("textures/*.png");
ok(@files, "Found PNGs");

for my $f (@files) {
    ok(-f $f, "$f exists");

    # pngcheck metadata
    my $out = `pngcheck -v "$f" 2>&1`;
    ok($out !~ /tEXt|zTXt|iTXt/, "$f has no text metadata") or diag($out);

    # optipng dry-run
    my $simulate = `optipng -strip all -simulate "$f" 2>&1`;
    
    if ($simulate =~ /is already optimized\./i) {
        pass("$f is already optimized");
    } else {
        fail("$f needs optimization or metadata stripping");
        diag($simulate);
    }
}

done_testing();