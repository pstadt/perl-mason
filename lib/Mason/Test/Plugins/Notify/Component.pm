package Mason::Test::Plugins::Notify::Component;
use Moose::Role;
use namespace::autoclean;

# This doesn't work - it interrupts the inner() chain. Investigate later.
#
#  before 'render' => sub {
#      my ($self) = @_;
#      print STDERR "starting component render - " . $self->cmeta->path . "\n";
#  };

1;
