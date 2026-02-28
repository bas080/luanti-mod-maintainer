use strict;
use warnings;
use Test::More;
use File::Find;

my $mod_dir = '.';

# Find all Lua files
my @lua_files;
find(
    sub { push @lua_files, $File::Find::name if /\.lua$/ },
    $mod_dir
);

ok(@lua_files, "Found Lua files in the mod");

my $needs_translation = 0;
my $found_translator  = 0;
my @violations;

for my $file (@lua_files) {
    open my $fh, '<', $file or die "Cannot open $file: $!";

    my $in_register = 0;

    while (my $line = <$fh>) {

        $found_translator = 1
            if $line =~ /(?:minetest|core)\.get_translator\s*\(/;

        $in_register = 1 if $line =~ /minetest\.register_/;
        $in_register = 0 if $line =~ /^\s*}\s*\)\s*$/;

        if ($in_register &&
            $line =~ /(description|short_description)\s*=\s*"([^"]+)"/) {
            $needs_translation = 1;
            push @violations, "$file: $1 not wrapped in S(): $2"
                unless $line =~ /\bS\s*\(/;
        }

        if ($line =~ /chat_send_(?:player|all)\s*\([^,]+,\s*"([^"]+)"/) {
            $needs_translation = 1;
            push @violations, "$file: chat string not wrapped in S(): $1"
                unless $line =~ /\bS\s*\(/;
        }
    }

    close $fh;
}

if (!$needs_translation) {
    pass("No translatable strings found");
    done_testing();
    exit;
}

ok($found_translator, "translator initialized");
ok(!@violations, "no raw user-facing strings")
    or diag(join "\n", @violations);

my @tr_files = glob("locale/*.tr");
my @po_files = glob("locale/*.po");

ok(!@tr_files, "No legacy .tr files found");
ok(@po_files, "Found .po translation files")
    or diag("Add at least one .po file in locale/");

for my $file (@po_files) {
    open my $fh, '<:encoding(UTF-8)', $file
        or do { fail("Cannot open $file: $!"); next };

    my $first_line = <$fh> // '';
    chomp $first_line;
    ok($first_line eq 'msgid ""', "$file starts with msgid header");

    while (my $line = <$fh>) {
        chomp $line;
        ok(
            $line =~ /^\s*$/ ||
            $line =~ /^(msgid|msgstr|")/,
            "$file: line looks valid"
        );
    }

    close $fh;
}

done_testing();