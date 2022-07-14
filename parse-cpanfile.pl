use strict;
use warnings;
use Module::CPANfile;
use Carton::Snapshot;
use JSON::XS;

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

print encode_json($cpanfile_manifest);

# my $snapshot = carton::snapshot->new(path => 'cpanfile.snapshot');
# $snapshot->load;
#
# for my $pkg ($snapshot->packages) {
#     p $pkg;
# }
