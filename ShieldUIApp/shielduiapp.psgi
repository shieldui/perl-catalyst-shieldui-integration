use strict;
use warnings;

use ShieldUIApp;

my $app = ShieldUIApp->apply_default_middlewares(ShieldUIApp->psgi_app);
$app;

