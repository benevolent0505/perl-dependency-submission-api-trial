use strict;
use warnings;

use JSON::XS;
use POSIX qw(strftime);

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
$cpanfile_manifest->{'cpanfile.snapshot'}->{resolved} = $resolved;

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