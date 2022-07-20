use strict;
use warnings;

use JSON::XS;
use POSIX qw(strftime);
use Search::Elasticsearch;

my $cpanfile_manifest = {};
$cpanfile_manifest->{'cpanfile.snapshot'} = +{
    name     => 'cpanfile.snapshot',
    file     => +{
        source_location => 'cpanfile.snapshot',
    },
};

my $resolved = {};
while (my $line = <STDIN>) {
    chomp $line;

    if ($line =~ /(.+)\s\((.+)\)/) {
        my $distribution = $1;
        my $version = $2;

        $resolved->{$distribution} = {
            package_url => sprintf("pkg:cpan/%s\@%s", $distribution, $version),
        };
    }
}

my $modules = [ keys %$resolved ];

my $es = Search::Elasticsearch->new(
    nodes            => 'https://fastapi.metacpan.org/v1',
    cxn_pool         => 'Static::NoPing',
    send_get_body_as => 'POST',
    client           => '2_0::Direct',
);

my @must = (
    { terms => { 'main_module' => $modules } },
    { term => { 'resources.repository.type' => 'git' }, },
    { term => { status                      => 'latest' } },
    { term => { authorized                  => 'true' } },
);

my $scroller = $es->scroll_helper(
    body        => {
        query => {
            bool => { must => \@must },
        },
    },
    _source     => [ 'main_module', 'resources.repository' ],
    search_type => 'scan',
    scroll      => '5m',
    index       => 'cpan',
    type        => 'release',
    size        => scalar(@$modules),
);

use DDP;

while ( my $result = $scroller->next ) {
    my $res = $result->{_source};

    my $main_module = $res->{main_module};
    my $repository = $res->{resources}->{repository};

    my $namespace = '';
    my $name = '';

    my $web = $repository->{web};
    my $url = $repository->{url};
    if (defined $web) {
        ($namespace, $name) = $web =~ /https:\/\/github\.com\/(.+)\/(.+)/;
    } else {
        ($namespace, $name) = $url =~ /git:\/\/github\.com\/(.+)\/(.+)\.git/;
        unless ($namespace && $name) {
            ($namespace, $name) = $url =~ /https:\/\/github\.com\/(.+)\/(.+)/;
        }
    }

    if ($namespace && $name) {
        $resolved->{$main_module} = {
            package_url => sprintf("pkg:github/%s/%s", $namespace, $name),
        };
    }
}

$cpanfile_manifest->{'cpanfile.snapshot'}->{resolved} = $resolved;

my $sha = $ENV{GITHUB_SHA} // 'dummy_sha';
my $job = $ENV{GITHUB_JOB} // 'dummy_job';
my $run_id = $ENV{GITHUB_RUN_ID} // 'dummy_id';
my $now = time();

my $manifest = +{
    version => 0,
    sha => $sha,
    ref => 'refs/heads/main',
    job => {
        correlator => $job,
        id         => $run_id,
    },
    detector   => {
        name    => 'perl detector',
        version => '0.0.1',
        url     => 'https://github.com/benevolent0505/perl-cpan-dep-test',
    },
    scanned    => strftime('%Y-%m-%dT%H:%M:%SZ', gmtime($now)),
    manifests => $cpanfile_manifest,
};

print encode_json($manifest);