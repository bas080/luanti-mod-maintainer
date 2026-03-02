use strict;
use warnings;
use Test::More;
use JSON;
use File::Find;

# ----- 1. Check LICENSE.txt -----
my $license_file = "LICENSE.txt";
ok(-f $license_file, "LICENSE.txt exists") or BAIL_OUT("LICENSE.txt not found");

open my $lfh, '<', $license_file or die "Cannot open $license_file: $!";
local $/;
my $license_text = <$lfh>;
close $lfh;

ok(
    $license_text =~ /(GNU LESSER GENERAL PUBLIC LICENSE|LGPL)/i,
    "LICENSE.txt contains LGPL license"
);

ok(
    $license_text =~ /2\.1/,
    "LICENSE.txt is specifically LGPL-2.1"
);

# ----- 2. Check .cdb.json -----
my $cdb_file = ".cdb.json";
ok(-f $cdb_file, ".cdb.json exists") or BAIL_OUT(".cdb.json not found");

open my $cfh, '<', $cdb_file or die "Cannot open $cdb_file: $!";
local $/;
my $json_text = <$cfh>;
close $cfh;

my $data = eval { decode_json($json_text) };
ok($data, ".cdb.json is valid JSON") or BAIL_OUT("Invalid JSON: $@");

# 2a. Check license field
ok(exists $data->{license}, ".cdb.json has 'license' field")
    or BAIL_OUT("Missing license field in .cdb.json");

is($data->{license}, 'LGPL-2.1', "ContentDB license field is LGPL-2.1");

# ----- 2b. Media license rules -----

# Detect media assets
my $has_media = 0;

for my $dir (qw(textures sounds)) {
    next unless -d $dir;

    find(
        sub {
            $has_media = 1 if /\.(png|ogg|wav)$/i;
        },
        $dir
    );
}

ok(exists $data->{media_license}, ".cdb.json has 'media_license' field")
    or BAIL_OUT("Missing media_license field in .cdb.json");

my $media_license = $data->{media_license};

if ($has_media) {

    my @accepted = qw(CC0 CC-BY CC-BY-SA PublicDomain);

    ok(
        grep { $_ eq $media_license } @accepted,
        "media_license is approved for media assets"
    );

} else {

    is(
        $media_license,
        $data->{license},
        "media_license matches code license when no media assets exist"
    );
}

# ----- 3. Check textures (existence only) -----
my $texture_dir = "textures";
if (-d $texture_dir) {
    my @pngs;

    
    find(sub { push @pngs, $File::Find::name if /\.png$/i }, $texture_dir);
    ok(@pngs, "Found PNG textures in $texture_dir");

    for my $png (@pngs) {
        ok(-f $png, "$png exists");
    }

    if (@pngs) {
        my @license_files;
        find(
            sub {
                push @license_files, $File::Find::name
                    if /^(LICENSE|COPYING|CC0)(\.txt)?$/i;
            },
            $texture_dir
        );

        ok(
            @license_files,
            "License file exists in textures directory when images are present"
        );
    }    
} else {
    note("No textures directory found; skipping texture files check");
}

done_testing();
