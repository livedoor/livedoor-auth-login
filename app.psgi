#!/usr/bin/env perl

use strict;
use warnings;
use Amon2::Lite;
use WebService::Livedoor::Auth;

my $usage = 'Please set env APP_KEY and APP_SECRET.';
my $app_key = $ENV{APP_KEY} or die $usage;
my $secret = $ENV{APP_SECRET} or die $usage;

my $auth = WebService::Livedoor::Auth->new({
    app_key => $app_key,
    secret => $secret,
});

printf("setup WebService::Livedoor::Auth app_key:%s secret:%s\n", $app_key, $secret);

get '/' => sub {
    my ($c) = @_;
    my $uri = $auth->uri_to_login(perms => 'id'); # livedoor IDを取得する場合 perms => 'id' の指定が必須です
    return $c->redirect($uri);
};

get '/callback' => sub {
    my ($c) = @_;
    my $user = $auth->validate_response($c->req);
    if ($user) {
        my $livedoor_id = $auth->get_livedoor_id($user) or return $c->render('error.tt', { error => $auth->errstr });
        return $c->render('index.tt', { livedoor_id => $livedoor_id });
    } else {
        # LOGIN ERROR.
        return $c->render('error.tt');
    }
};

__PACKAGE__->to_app();

__DATA__

@@ index.tt
<!doctype html>
<html>
    <body>Hello [% livedoor_id %]</body>
</html>

@@ error.tt
<!doctype html>
<html>
    <body>Error [% error %]</body>
</html>
