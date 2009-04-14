package MooseX::NonMoose::Meta::Role::Constructor;
use Moose::Role;

around can_be_inlined => sub {
    my $orig = shift;
    my $self = shift;

    my $meta = $self->associated_metaclass;
    my $super_new = $meta->find_method_by_name($self->name);
    # XXX is this even the right test?
    if (!$super_new->associated_metaclass->isa($self->_expected_constructor_class)) {
        return 1;
    }

    return $self->$orig(@_);
};

sub _generate_instance {
    my $self = shift;
    my ($var, $class_var) = @_;
    my $new = $self->name;
    my $super_new_class = $self->associated_metaclass->find_next_method_by_name($new)->package_name;
    "my $var = bless $super_new_class->$new(\@_), $class_var;\n";
}

no Moose::Role;

1;