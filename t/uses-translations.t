use strict;
use warnings;
use Test::More;
use File::Find;

my $mod_dir = '.';

ok(-d "locale", "locale directory exists");

my @tr_files = glob("locale/*.tr");
ok(@tr_files > 0, "translation files exist");

my @lua_files;
find(
  sub { push @lua_files, $File::Find::name if /\.lua$/ },
  $mod_dir
);

my $found_translator = 0;
my @violations;

for my $file (@lua_files) {
  open my $fh, '<', $file or die $!;
  my $in_register = 0;

  while (my $line = <$fh>) {

    $found_translator = 1
      if $line =~ /(?:minetest|core)\.get_translator\s*\(/;

    # detect entering register block
    $in_register = 1 if $line =~ /minetest\.register_/;

    # crude block end detection
    $in_register = 0 if $line =~ /^\s*}\s*\)\s*$/;

    next unless $in_register;

    # fields that must use S()
    if ($line =~ /(description|short_description)\s*=\s*"([^"]+)"/) {
      push @violations, "$file: $1 not wrapped in S(): $2";
    }

    if ($line =~ /(description|short_description)\s*=\s*[^S]/) {
      push @violations, "$file: $1 likely not using S()"
        unless $line =~ /\bS\s*\(/;
    }

    # chat functions
    if ($line =~ /chat_send_(?:player|all)\s*\([^,]+,\s*"([^"]+)"/) {
      push @violations, "$file: chat string not wrapped in S(): $1";
    }
  }

  close $fh;
}

ok($found_translator, "translator initialized");

ok(!@violations, "no raw user-facing strings")
  or diag(join "\n", @violations);

done_testing();