use strict;
use warnings;
use Test::More;

my $remote = 'origin';

# Get the latest local tag
my $tag = `git describe --tags --abbrev=0 2>/dev/null`;
chomp $tag;

if (!$tag) {
    fail("No local git tag found");
    done_testing();
    exit;
}

# Check if the tag exists on remote
my $remote_tags = `git ls-remote --tags $remote 2>/dev/null`;

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