use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ShieldUIApp';
use ShieldUIApp::Controller::Book;

ok( request('/book')->is_success, 'Request should succeed' );
done_testing();
