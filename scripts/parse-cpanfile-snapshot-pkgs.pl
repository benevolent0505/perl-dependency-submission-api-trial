use strict;
use warnings;

use Carton::Snapshot;
use DDP;

my $cpanfile_snapshot_path = $ENV{CPANFILE_SNAPSHOT_PATH} // 'cpanfile.snapshot';

my $snapshot = Carton::Snapshot->new(path => $cpanfile_snapshot_path);
$snapshot->load;

for my $pkg ($snapshot->distributions) {
    p $pkg->provides;
}