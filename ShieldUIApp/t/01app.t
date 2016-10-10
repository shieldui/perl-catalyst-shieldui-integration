#!C:\Perl\bin\perl.exe
use strict;
use warnings;
use Test::More;

use Catalyst::Test 'ShieldUIApp';

ok( request('/')->is_success, 'Request should succeed' );

done_testing();
