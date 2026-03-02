use strict;
use warnings;
use Test::More;

my $remote = 'origin'; # or your remote name
my $tag = `git describe --tags --abbrev=0`;
chomp $tag;
BAIL_OUT("No local git tag found") unless $tag;

# List remote tags
my $remote_tags = `git ls-remote --tags $remote`;
ok($remote_tags =~ /\Q$tag\E/, "Latest tag '$tag' is pushed to remote '$remote'");

done_testing();