
=pod 

=head1 NAME

    Bio::EnsEMBL::Hive::TestAnalysis

=head1 DESCRIPTION



=head1 LICENSE

    Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

    Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License
    is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

=head1 CONTACT

    Please subscribe to the Hive mailing list:  http://listserver.ebi.ac.uk/mailman/listinfo/ehive-users  to discuss Hive-related questions or to be notified of our updates

=head1 APPENDIX

    The rest of the documentation details each of the object methods.
    Internal methods are usually preceded with a _

=cut

package Bio::EnsEMBL::Hive::TestAnalysis;

use strict;
use warnings;

use Bio::EnsEMBL::Hive::AnalysisJob;
use Bio::EnsEMBL::Hive::Utils ('load_file_or_module');
use Carp;

sub new {
    my $class = shift @_;

    my $self = bless {}, $class;

    while ( my ( $method, $value ) = splice( @_, 0, 2 ) ) {
        if ( defined($value) ) {
            $self->$method($value);
        }
    }

    return $self;
}

sub run_job {
    my $self = shift;

    my $runnable_object = $self->_prepare_runnable_object();
    my $job             = $self->_prepare_analysis_job();

    $job->param_init( 0, $self->params() );

    $runnable_object->input_job($job);
    $runnable_object->life_cycle();

    $self->died(1) if ( $job->died_somewhere() );

    $runnable_object->cleanup_worker_temp_directory() if ( $self->cleanup() );
}

sub _prepare_runnable_object {
    my $self = shift;

    my $module_name = $self->module_name();
    confess("Module name is required") unless $module_name;

    my $runnable_module = load_file_or_module($module_name);
    my $runnable_object = $runnable_module->new();

    $self->runnable($runnable_object);

    $runnable_object->debug( $self->debug() );
    $runnable_object->execute_writes(1);

    return $runnable_object;
}

sub _prepare_analysis_job {
    my $self = shift;

    my $job = Bio::EnsEMBL::Hive::AnalysisJob->new( 'dbID' => -1 );

    my $output_log = [];
    $self->dataflow_output_log($output_log);

    _monkey_patch_instance(
        $job,
        'dataflow_output_id' => sub {
            my ( $ajob, $output_ids, $branch_name_or_code, $create_job_options )
              = @_;
              
            push @$output_log,
              {
                output_ids          => $output_ids,
                branch_name_or_code => $branch_name_or_code,
                create_job_options  => $create_job_options
              };
        }
    );

    $self->job($job);
    $job->input_id( $self->input_id() );
    $job->autoflow(1);

    return $job;
}

sub _monkey_patch_instance {
    my ( $instance, $method, $code ) = @_;
    my $package = ref($instance) . '::MonkeyPatch';
    no strict 'refs';
    @{ $package . '::ISA' } = ( ref($instance) );
    *{ $package . '::' . $method } = $code;
    bless $_[0], $package;    # sneaky re-bless of aliased argument
}

sub runnable {
    my $self = shift;
    $self->{'_runnable'} = shift if (@_);
    return $self->{'_runnable'};
}

sub job {
    my $self = shift;
    $self->{'_job'} = shift if (@_);
    return $self->{'_job'};
}

sub died {
    my $self = shift;
    $self->{'_died'} = shift if (@_);
    return $self->{'_died'};
}

sub module_name {
    my $self = shift;
    $self->{'_module_name'} = shift if (@_);
    return $self->{'_module_name'};
}

sub debug {
    my $self = shift;
    $self->{'_debug'} = shift if (@_);
    return $self->{'_debug'};
}

sub cleanup {
    my $self = shift;
    $self->{'_cleanup'} = shift if (@_);
    return $self->{'_cleanup'};
}

sub params {
    my $self = shift;
    $self->{'_params'} = shift if (@_);
    return $self->{'_params'};
}

sub input_id {
    my $self = shift;
    $self->{'_input_id'} = shift if (@_);
    return $self->{'_input_id'};
}

sub dataflow_output_log {
    my $self = shift;
    $self->{'_dataflow_output_log'} = shift if (@_);
    return $self->{'_dataflow_output_log'};
}

sub execute_writes {
    my $self = shift;
    $self->{'_execture_writes'} = shift if (@_);
    return $self->{'_execture_writes'};
}
1;
