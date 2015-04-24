use strict;
use warnings;

use Bio::EnsEMBL::Hive::TestRunnable;
use Test::More;
use Data::Dumper;

my $test_harness = Bio::EnsEMBL::Hive::TestRunnable->new(
    module_name => 'Bio::EnsEMBL::Hive::RunnableDB::LongMult::PartMultiply',
    params      => {},
    input_id    => { a_multiplier => 1138, digit => 7 },
);

$test_harness->run();

is_deeply(
    $test_harness->dataflow_output_log(),
    [
        {
            'branch_name_or_code' => 1,
            'create_job_options'  => undef,
            'output_ids'          => { 'partial_product' => '7966' },
        },
    ],
    'dataflow_output_log'
) || $test_harness->dump_diagnostics;

done_testing();
