use strict;
use warnings;
use Module::CPANfile;
use Carton::Snapshot;
use JSON::XS;
use POSIX qw(strftime);

my $file = Module::CPANfile->load('cpanfile');
my $prereqs = $file->prereqs;

my $cpanfile_manifest = {};
$cpanfile_manifest->{'cpanfile'} = +{
    name     => 'cpanfile',
    file     => +{
        source_location => 'cpanfile',
    },
};
my $resolved = {};
for (values %{ $prereqs->as_string_hash }) {
    my $v = $_->{requires};
    for my $k (keys %$v) {
        $resolved->{$k} = {
            package_url => sprintf("pkg:/metacpan/%s\@%s", $k, $v->{$k}),
        };
    }
}
$cpanfile_manifest->{cpanfile}->{resolved} = $resolved;

my $sha = $ENV{GITHUB_SHA};
my $job = $ENV{GITHUB_JOB};
my $run_id = $ENV{GITHUB_RUN_ID};
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