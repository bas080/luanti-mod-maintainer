#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;

my $cmd = 'stylua . --glob "**/*.lua" --indent-type Spaces --column-width 120';
my $output = `$cmd 2>&1`;
my $exit = $? >> 8;

ok($exit == 0, "All Lua files pass stylua check") or diag($output);
