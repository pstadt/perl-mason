package Mason::Component::ClassMeta;
use Moose;
use Mason::Moose;
use Log::Any;
use strict;
use warnings;

# Passed attributes (generated in compiled component)
has 'class'       => ( required => 1 );
has 'dir_path'    => ( required => 1 );
has 'interp'      => ( required => 1, weak_ref => 1 );
has 'is_external' => ( required => 1 );
has 'object_file' => ( required => 1 );
has 'path'        => ( required => 1 );
has 'source_file' => ( required => 1 );

# Derived attributes
has 'cache' => ( init_arg => undef, lazy_build => 1 );
has 'log' => ( init_arg => undef, lazy_build => 1 );

# These only exist in InstanceMeta
foreach my $method (qw(args)) {
    __PACKAGE__->meta->add_method(
        $method => sub {
            my $self = shift;
            die sprintf( "cannot call %s() from %s->cmeta", $method, $self->class );
        }
    );
}

method _build_cache () {
    my $interp         = $self->interp;
    my $chi_root_class = $interp->chi_root_class;
    Class::MOP::load_class($chi_root_class);
    my %options = ( %{ $interp->chi_default_params }, @_ );
    if ( !exists( $options{namespace} ) ) {
        $options{namespace} = $self->path;
    }
    return $chi_root_class->new(%options);
}

method _build_log () {
    my $log_category = "Mason::Component" . $self->path;
    $log_category =~ s/\//::/g;
    return Log::Any->get_logger( category => $log_category );
}

__PACKAGE__->meta->make_immutable();

1;

# ABSTRACT: Meta-information about Mason component class
__END__

=head1 SYNOPSIS

    # In a component:
    My path is <% $.cmeta->path %>
    My source file is <% $.cmeta->source_file %>

=head1 DESCRIPTION

Every L<Mason::Component|Mason::Component> class has an associated
L<Mason::Component::ClassMeta|Mason::Component::ClassMeta> object, containing
meta-information such as the component's path and source file. It can be
accessed with the L<Mason::Component/cmeta> method.

When called from an instance, a
L<Mason::Component::InstanceMeta|Mason::Component::InstanceMeta> is returned,
which supplies all the information here plus a few other things such as the
arguments the instance was created with.

=over

=item cache

=item dir_path

The directory of the component path, relative to the component root - e.g. for
a component '/foo/bar', the dir_path is '/foo'.

=item object_file

The object file produced from compiling the component.

=item path

The component path, relative to the component root - e.g. '/foo/bar'.

=item source_file

The component source file.

=back

=head1 SEE ALSO

L<Mason|Mason>

=cut