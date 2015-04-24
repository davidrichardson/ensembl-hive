use strict;
use warnings;

use Bio::EnsEMBL::Hive::TestAnalysis;
use Test::More;

my $test_harness = Bio::EnsEMBL::Hive::TestAnalysis->new(
    module_name => 'Bio::EnsEMBL::Hive::RunnableDB::LongMult::PartMultiply',
    params      => { a_multiplier => 1138, digit => 7 },
    input_id    => {},
);

$test_harness->run_job();

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
);

done_testing();
