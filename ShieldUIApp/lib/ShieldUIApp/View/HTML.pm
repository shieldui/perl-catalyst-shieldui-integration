package ShieldUIApp::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

ShieldUIApp::View::HTML - TT View for ShieldUIApp

=head1 DESCRIPTION

TT View for ShieldUIApp.

=head1 SEE ALSO

L<ShieldUIApp>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
