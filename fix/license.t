use strict;
use warnings;
use Test::More;
use JSON;
use LWP::Simple;

# ----- 1. Fix LICENSE.txt -----
my $license_file = "LICENSE.txt";
my $lgpl_url = "https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt";

my $license_text = get($lgpl_url);
ok($license_text, "Fetched LGPL 2.1 text") or BAIL_OUT("Failed to fetch LGPL text");

open my $lfh, '>', $license_file or die "Cannot write to $license_file: $!";
print $lfh $license_text;
close $lfh;
pass("LICENSE.txt updated with LGPL-2.1");

# ----- 2. Fix .cdb.json -----
my $cdb_file = ".cdb.json";
my $data = {};

if (-f $cdb_file) {
    open my $cfh, '<', $cdb_file or die "Cannot open $cdb_file: $!";
    local $/;
    my $json_text = <$cfh>;
    close $cfh;
    $data = eval { decode_json($json_text) } || {};
}

# Update code license
$data->{license} = 'LGPL-2.1';

# Only set media_license if textures directory exists
if (-d "textures") {
    $data->{media_license} = 'CC0';
} else {
    delete $data->{media_license} if exists $data->{media_license};
}

# Write back
open my $cfh, '>', $cdb_file or die "Cannot write to $cdb_file: $!";
print $cfh JSON->new->canonical(1)->pretty(1)->encode($data);
close $cfh;
pass(".cdb.json license fields updated appropriately");

done_testing();
