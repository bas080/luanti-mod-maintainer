use strict;
use warnings;
use Test::More;
use JSON;
use LWP::UserAgent;

# ----- Config -----
my $origin  = $ENV{CONTENTDB_ORIGIN} // 'https://content.luanti.org';
my $api_key = $ENV{CONTENTDB_API_KEY} or BAIL_OUT("CONTENTDB_API_KEY not set");

# ----- Read .cdb.json -----
open my $fh, '<', '.cdb.json' or BAIL_OUT("Missing .cdb.json");
local $/;
my $cdb = decode_json(<$fh>);
close $fh;

my $author = $ENV{'CONTENTDB_AUTHOR'};
my $name   = $cdb->{name} // '';
BAIL_OUT("Missing author/name") unless $author && $name;

# ----- Get last two tags -----
my @tags = split /\n/, `git tag --sort=-creatordate`;
BAIL_OUT("No git tags found") unless @tags;

my $version = $tags[0];          # latest tag
my $prev_tag = $tags[1] // '';   # previous tag

# ----- Push master branch -----
system('git push origin master') == 0
    or BAIL_OUT("Failed to push master branch to remote");

# ----- Push tags -----
system('git push --tags') == 0
    or BAIL_OUT("Failed to push git tags to remote");

# ----- Get changelog diff -----
my $diff;
if ($prev_tag) {
    $diff = `git diff $prev_tag..$version -- CHANGELOG.md | grep '^+[^+]'`;
} else {
    open my $ch, '<', 'CHANGELOG.md' or BAIL_OUT("CHANGELOG.md missing");
    local $/;
    $diff = <$ch>;
    close $ch;
}

$diff =~ s/^\+//mg;
$diff =~ s/\r\n?/\n/g;
$diff =~ s/\s+\z//;

BAIL_OUT("No changelog additions detected") unless $diff;
my $release_notes = $diff;

# ----- Create release -----
my $ua = LWP::UserAgent->new;
my $url = "$origin/api/packages/$author/$name/releases/new/";

my $payload = encode_json({
    version       => $version,
    title         => $version,
    release_notes => $release_notes,
    method        => "git",
    ref           => $version,
});

my $req = HTTP::Request->new(POST => $url);
$req->header('Authorization' => "Bearer $api_key");
$req->header('Content-Type'  => 'application/json');
$req->content($payload);

my $res = $ua->request($req);
my $resp = decode_json($res->decoded_content);

if ($resp->{success}) {
    pass("Release created with release_notes including changelog diff");
} else {
    diag("Release creation failed: " . ($resp->{error} // "Unknown error"));
    fail("Could not create release");
}

done_testing();
