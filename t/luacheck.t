use strict;
use warnings;
use Test::More;
use Cwd 'abs_path';
use File::Basename;

# Get the directory of this test file
my $test_dir = dirname(abs_path($0));

# .luacheckrc is in the parent of the t/ directory
my $config_path = "$test_dir/../.luacheckrc";

# Check luacheck exists
my $luacheck = `which luacheck 2>/dev/null`;
chomp $luacheck;
ok($luacheck, "luacheck is installed") or BAIL_OUT("luacheck not found");

# Run luacheck on current mod directory (assume '.' is mod root)
my $cmd = "luacheck -q --config $config_path .";
my $output = `$cmd 2>&1`;
my $exit = $? >> 8;

ok($exit == 0, "luacheck passes") or diag($output);

done_testing();