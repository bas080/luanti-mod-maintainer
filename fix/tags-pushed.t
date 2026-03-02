use strict;
use warnings;
use Test::More;

my $remote = 'origin'; # change if your remote has a different name

# Get the latest local tag
my $tag = `git describe --tags --abbrev=0`;
chomp $tag;
BAIL_OUT("No local git tag found") unless $tag;

# Check if the tag exists on remote
my $remote_tags = `git ls-remote --tags $remote`;
if ($remote_tags =~ /\Q$tag\E/) {
    pass("Tag '$tag' already exists on remote '$remote'");
} else {
    note("Tag '$tag' missing on remote, pushing...");
    my $push_output = `git push $remote $tag 2>&1`;
    my $exit = $? >> 8;

    if ($exit == 0) {
        pass("Tag '$tag' successfully pushed to '$remote'");
    } else {
        diag("Failed to push tag:\n$push_output");
        fail("Could not push tag '$tag' to '$remote'");
    }
}

done_testing();