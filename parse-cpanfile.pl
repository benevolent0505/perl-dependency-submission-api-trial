use strict;
use warnings;
use Module::CPANfile;
use Carton::Snapshot;
use DDP;

my $file = Module::CPANfile->load('cpanfile');
my $prereqs = $file->prereqs;
p $prereqs->as_string_hash;

my $snapshot = Carton::Snapshot->new(path => 'cpanfile.snapshot');
$snapshot->load;

for my $pkg ($snapshot->packages) {
    p $pkg;
}
