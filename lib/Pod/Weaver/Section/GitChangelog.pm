package Pod::Weaver::Section::GitChangelog 0.01;
# ABSTRACT: Add Pod::Weaver section with GIT file commit messages formatted as customized list

=head1 SYNOPSIS

In your C<weaver.ini>:

	[GitChangelog / GIT CHANGELOG]
	header = GIT CHANGELOG
	mode = file
	filter = /^\((new|chg)\) |^\[(new|chg)\] |^(new|chg): /
	rules = s/^\[(new|chg)\]/($1)/ && s/^(new|chg): /($1)/ && s/\.$//
	format = "  %10{date}  %14{author}  %{message}"
	conversion_map = ~/old-commits.map

=head1 DESCRIPTION

xxx

=head1 SEE ALSO

L<Pod::Weaver>

=cut

use strict;
use warnings;

use Moose;

with 'Pod::Weaver::Role::Section';

use aliased 'Pod::Elemental::Element::Nested';
use aliased 'Pod::Elemental::Element::Pod5::Command';

has mode => (
	is => 'ro',
	isa => 'Str',
	lazy => 1,
	default => 'file',
);

has filter => (
	is => 'ro',
	isa => 'Str',
	lazy => 1,
);

has rules => (
	is => 'ro',
	isa => 'Str',
	lazy => 1,
);

has format => (
	is => 'ro',
	isa => 'Str',
	lazy => 1,
	default => ' %10{date}  %{message}',
);

has conversion_map => (
	is => 'ro',
	isa => 'Str',
	lazy => 1,
);

has header => (
	is => 'ro',
	isa => 'Str',
	lazy => 1,
	required => 1,
	default => sub { $_[0]->plugin_name },
);

has extra_args => (
	is	=> 'rw',
	isa	=> 'HashRef',
);

sub BUILD {
    my $self = shift;
    my ($args) = @_;
    my $copy = {%$args};
    delete $copy->{$_}
        for map { $_->init_arg } $self->meta->get_all_attributes;
    $self->extra_args($copy);
}

sub weave_section {
    my ( $self, $doc, $input ) = @_;

    push @{ $doc->children },
		Nested->new( {
            type     => 'command',
            command  => 'head1',
            content  => $self->header,
            children => [
				Pod::Elemental::Element::Pod5::Ordinary->new( { content => 'log...' } )
			]
        } );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
