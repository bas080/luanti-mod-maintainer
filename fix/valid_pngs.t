use strict;
use warnings;
use Test::More;
use File::Find;

my $texture_dir = "textures";

if (!-d $texture_dir) {
    note("No textures/ directory found, nothing to fix");
    done_testing();
    exit 0;
}

# Find all PNG files
my @pngs;
find(sub { push @pngs, $File::Find::name if /\.png$/i }, $texture_dir);

ok(@pngs, "Found PNG files in $texture_dir");

for my $file (@pngs) {
    ok(-f $file, "$file exists");

    # Call optipng to strip metadata
    my $cmd = "optipng -strip all -quiet " . $file;
    my $status = system($cmd);

    if ($status == 0) {
        pass("Metadata stripped from $file");
    } else {
        fail("Failed to process $file with optipng");
        diag("Command: $cmd exited with $status");
    }
}

done_testing();