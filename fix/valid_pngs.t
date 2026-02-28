use strict;
use warnings;
use Test::More;
use File::Find;

my $texture_dir = "textures";
my $init_file   = "init.lua";

# Skip if no init.lua
if (!-f $init_file) {
    note("No init.lua found, nothing to check");
    done_testing();
    exit 0;
}

# Check if mod defines textures in init.lua
open my $fh, '<', $init_file or die "Cannot open $init_file: $!";
my $defines_textures = 0;
while (<$fh>) {
    if (/\btiles\s*=|\btextures\s*=/) {
        $defines_textures = 1;
        last;
    }
}
close $fh;

if (!$defines_textures) {
    note("Mod does not define textures, skipping");
    done_testing();
    exit 0;
}

# Skip if textures/ directory missing
if (!-d $texture_dir) {
    note("No textures/ directory found");
    done_testing();
    exit 0;
}

# Find all PNG files
my @pngs;
find(sub { push @pngs, $File::Find::name if /\.png$/i }, $texture_dir);

ok(@pngs, "Found PNG files in $texture_dir");

for my $file (@pngs) {
    ok(-f $file, "$file exists");

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