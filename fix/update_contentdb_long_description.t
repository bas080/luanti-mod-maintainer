use strict;
use warnings;
use Test::More;
use JSON;
use LWP::UserAgent;

# Config from environment
my $origin = $ENV{CONTENTDB_ORIGIN} // 'https://content.luanti.org';
my $api_key = $ENV{CONTENTDB_API_KEY} or BAIL_OUT("CONTENTDB_API_KEY not set");

# Assume mod root is current directory
my $mod_root = '.';

# Load .cdb.json
my $cdb_file = "$mod_root/.cdb.json";
ok(-f $cdb_file, ".cdb.json exists") or BAIL_OUT(".cdb.json not found");

open my $fh, '<', $cdb_file or die "Cannot open .cdb.json: $!";
local $/;
my $json_text = <$fh>;
close $fh;

my $cdb_data = decode_json($json_text);
my $author = $cdb_data->{author} // $cdb_data->{maintainers}->[0] // '';
my $name   = $cdb_data->{name} // '';
ok($author && $name, "Found author and name in .cdb.json") or BAIL_OUT("Missing author/name");

# Load local README
my $readme_file = "$mod_root/README.md";
ok(-f $readme_file, "README.md exists") or BAIL_OUT("README.md not found");

open my $rfh, '<', $readme_file or die "Cannot open README.md: $!";
local $/;
my $local_readme = <$rfh>;
close $rfh;

# Fetch remote long_description
my $ua = LWP::UserAgent->new;
my $get_url = "$origin/api/packages/$author/$name/";
my $res = $ua->get($get_url);
ok($res->is_success, "Fetched remote package info") or BAIL_OUT("Failed to fetch $get_url");

my $remote_data = decode_json($res->decoded_content);
my $remote_desc = $remote_data->{long_description} // '';
$remote_desc =~ s/\r\n?/\n/g;
$remote_desc =~ s/\s+$//mg;

# Compare
if ($local_readme eq $remote_desc) {
    pass("README.md matches ContentDB long_description — nothing to update");
} else {
    note("README.md differs — updating ContentDB long_description");

    # Prepare JSON payload
    my $payload = encode_json({ long_description => $local_readme });

    my $put_req = HTTP::Request->new(PUT => $get_url);
    $put_req->header('Authorization' => "Bearer $api_key");
    $put_req->header('Content-Type' => 'application/json');
    $put_req->content($payload);

    my $put_res = $ua->request($put_req);
    ok($put_res->is_success, "Updated ContentDB long_description") 
        or diag($put_res->status_line . "\n" . $put_res->decoded_content);
}

done_testing();
