use strict;
use warnings;
use Test::More;
use JSON;
use LWP::Simple;

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
    $data = eval { decode_json($json_text) } || {};
}

$data->{license} = 'LGPL-2.1';

if (-d "textures") {

    $data->{media_license} = 'CC0';

    # ----- 3. Ensure CC0.txt exists in textures -----
    my $cc0_file = "textures/LICENSE.txt";
    my $cc0_url  = "https://raw.githubusercontent.com/licenses/license-templates/refs/heads/master/templates/cc0.txt";

    unless (-f $cc0_file) {
        my $cc0_text = get($cc0_url);
        ok($cc0_text, "Fetched CC0 license text") or BAIL_OUT("Failed to fetch CC0 text");

        open my $ccfh, '>', $cc0_file or die "Cannot write to $cc0_file: $!";
        print $ccfh $cc0_text;
        close $ccfh;

        pass("Created textures/CC0.txt");
    } else {
        pass("textures/CC0.txt already exists");
    }

} else {
    delete $data->{media_license} if exists $data->{media_license};
}

open my $cfh, '>', $cdb_file or die "Cannot write to $cdb_file: $!";
print $cfh JSON->new->canonical(1)->pretty(1)->encode($data);
close $cfh;

pass(".cdb.json license fields updated appropriately");

done_testing();
