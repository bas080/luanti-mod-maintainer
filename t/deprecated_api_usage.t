use strict;
use warnings;
use Test::More;
use File::Find;

my @files;
find(
    sub {
        return unless -f;
        return unless /\.(lua|conf|txt|md)$/;
        push @files, $File::Find::name;
    },
    '.'
);

ok(@files, "Found project files");

my @violations;

# Deprecated patterns that apply to file contents generally
my %deprecated_patterns = (

    # Legacy files (handled via filename match later too)
    qr/"current_name"/ =>
        'Inventory location "current_name" is deprecated',

    # Formspec
    qr/invsize\[/ =>
        'invsize[] is deprecated, use fixed_size',
    qr/bgcolor_hovered\s*=/ =>
        'bgcolor_hovered is deprecated, use states',
    qr/bgcolor_pressed\s*=/ =>
        'bgcolor_pressed is deprecated, use states',
    qr/bgimg_hovered\s*=/ =>
        'bgimg_hovered is deprecated, use states',
    qr/bgimg_pressed\s*=/ =>
        'bgimg_pressed is deprecated, use states',
    qr/fgimg_hovered\s*=/ =>
        'fgimg_hovered is deprecated, use states',
    qr/fgimg_pressed\s*=/ =>
        'fgimg_pressed is deprecated, use states',

    # Namespace
    qr/\bcore\.env:/ =>
        'core.env: syntax is deprecated',

    # Noise
    qr/\bcore\.get_perlin\b/ =>
        'Renamed to core.get_value_noise',

    # Mapgen params
    qr/\bcore\.get_mapgen_params\b/ =>
        'Use core.get_mapgen_setting instead',
    qr/\bcore\.set_mapgen_params\b/ =>
        'Use core.set_mapgen_setting instead',

    # Old particles signatures (basic detection)
    qr/\bcore\.add_particlespawner\s*\(\s*\d/ =>
        'Old add_particlespawner signature is deprecated',

    # Item metadata
    qr/:get_metadata\s*\(/ =>
        'ItemStack:get_metadata is deprecated',
    qr/:set_metadata\s*\(/ =>
        'ItemStack:set_metadata is deprecated',

    # Player velocity
    qr/:get_player_velocity\s*\(/ =>
        'Use get_velocity instead',
    qr/:add_player_velocity\s*\(/ =>
        'Use add_velocity instead',

    # Look API
    qr/:get_look_pitch\s*\(/ =>
        'Use get_look_vertical',
    qr/:get_look_yaw\s*\(/ =>
        'Use get_look_horizontal',
    qr/:set_look_pitch\s*\(/ =>
        'Use set_look_vertical',
    qr/:set_look_yaw\s*\(/ =>
        'Use set_look_horizontal',

    # Player attributes
    qr/:set_attribute\s*\(/ =>
        'Use player:get_meta() instead',
    qr/:get_attribute\s*\(/ =>
        'Use player:get_meta() instead',

    # HUD
    qr/hud_elem_type\s*=/ =>
        'hud_elem_type is deprecated, use type',
);

for my $file (@files) {

    open my $fh, '<', $file or die "Cannot open $file: $!";
    local $/;
    my $content = <$fh>;
    close $fh;

    # -------------------------------------------------
    # File-specific deprecation checks
    # -------------------------------------------------

    # depends.txt deprecated
    if ($file =~ m{(^|/)depends\.txt$}) {
        push @violations,
          "$file: depends.txt is deprecated, use mod.conf";
    }

    # description.txt deprecated
    if ($file =~ m{(^|/)description\.txt$}) {
        push @violations,
          "$file: description.txt is deprecated, use mod.conf";
    }

    # game.conf specific rule
    if ($file =~ m{(^|/)game\.conf$}) {
        if ($content =~ /^\s*name\s*=/m) {
            push @violations,
              "$file: game.conf 'name' key is deprecated (use 'title')";
        }
    }

    # -------------------------------------------------
    # General content checks
    # -------------------------------------------------

    for my $pattern (keys %deprecated_patterns) {
        if ($content =~ $pattern) {
            push @violations,
              "$file: $deprecated_patterns{$pattern}";
        }
    }
}

ok(!@violations, "No deprecated API or constructs found")
    or diag(join "\n", @violations);

done_testing();