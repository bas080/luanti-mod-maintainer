use strict;
use warnings;
use Test::More;
use JSON;
use LWP::Simple;
use File::Path qw(make_path);

# ----- 1. Update LICENSE.txt -----
my $license_file = "LICENSE.txt";
my $lgpl_url     = "https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt";

my $license_text = get($lgpl_url);
ok($license_text, "Fetched LGPL 2.1 text") or BAIL_OUT("Failed to fetch LGPL text");

open my $lfh, '>', $license_file or die "Cannot write to $license_file: $!";
print $lfh $license_text;
close $lfh;
pass("LICENSE.txt updated with LGPL-2.1");

# ----- 2. Update .cdb.json safely -----
my $cdb_file = ".cdb.json";
my $data = {};

if (-f $cdb_file) {
    open my $cfh, '<', $cdb_file or die "Cannot open $cdb_file: $!";
    local $/;
    my $json_text = <$cfh>;
    close $cfh;
    eval { $data = decode_json($json_text) } or $data = {};
}

# Set code license
$data->{license} = 'LGPL-2.1-only';

# ----- 3. Handle media license -----
if (-d "textures") {
    $data->{media_license} = 'CC0-1.0';

    # Ensure textures/LICENSE.txt exists
    my $texture_license = "textures/LICENSE.txt";
    unless (-f $texture_license) {
        make_path("textures") unless -d "textures";
        my $cc0_text = get("https://raw.githubusercontent.com/licenses/license-templates/refs/heads/master/templates/cc0.txt");
        ok($cc0_text, "Fetched CC0 license text") or BAIL_OUT("Failed to fetch CC0 text");
        open my $tlfh, '>', $texture_license or die "Cannot write $texture_license: $!";
        print $tlfh $cc0_text;
        close $tlfh;
        pass("Created textures/LICENSE.txt");
    } else {
        pass("textures/LICENSE.txt already exists");
    }

} else {
    # No textures → media license matches code license
    $data->{media_license} = $data->{license};
}

# Write back .cdb.json
open my $cfh, '>', $cdb_file or die "Cannot write to $cdb_file: $!";
print $cfh JSON->new->canonical(1)->pretty(1)->encode($data);
close $cfh;

pass(".cdb.json license fields updated appropriately");

done_testing();