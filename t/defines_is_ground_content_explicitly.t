use strict;
use warnings;
use Test::More;
use File::Find;

my @lua_files;
find(
    sub { push @lua_files, $File::Find::name if /\.lua$/ },
    '.'
);

ok(@lua_files, "Found Lua files");

my @violations;

for my $file (@lua_files) {
    open my $fh, '<', $file or die "Cannot open $file: $!";
    local $/;
    my $content = <$fh>;
    close $fh;

    while ($content =~ /minetest\.register_node\s*\([^,]+,\s*{(.*?)\n\s*}\s*\)/sg) {
        my $block = $1;

        unless ($block =~ /\bis_ground_content\s*=/) {
            push @violations, "$file: register_node missing is_ground_content";
        }
    }
}

ok(!@violations, "All nodes define is_ground_content")
    or diag(join "\n", @violations);

done_testing();