use strict;
use warnings;
use App::Cmd::Tester;
use App::karyn;

use Test::More;

# Remove test keys by bucket
ok test_app('App::karyn' => [qw'delete -b b1']), 'clear bucket';
ok test_app('App::karyn' => [qw'delete -b b2']), 'clear bucket';
ok test_app('App::karyn' => [qw'delete -b b3']), 'clear bucket';
ok test_app('App::karyn' => [qw'delete -b b4']), 'clear bucket';

subtest 'add key/values' => sub {

    # add key/value
    is test_app('App::karyn' => [qw/add --bucket b1 --key k1 --value v1/])
      ->stdout => "204 No Content (Success)\n",
      'add key/value';
};

subtest 'list buckets' => sub {

    # list buckets
    like test_app('App::karyn' => [qw/list --bucket _/])->stdout =>
      qr/b1\n/,
      'list buckets';

    # list buckets defaults to underscore wildcard
    is test_app('App::karyn' => [qw/list/])->stdout =>
      test_app('App::karyn' => [qw/list --bucket _/])->stdout,
      'default list buckets';
};

subtest 'add keys' => sub {

    # Add bucket/key shortcut
    is test_app('App::karyn' => [qw'list b2/k2'])->stdout => "404 (Error)\n",
      'does not exist';
    is test_app('App::karyn' => [qw'add b2/k2 --value v2'])->stdout =>
      "204 No Content (Success)\n",
      'added';
    is test_app('App::karyn' => [qw'list b2/k2'])->stdout => "v2\n",
      'verified';
    #ok test_app('App::karyn' => [qw'delete -b b2']), 'clear bucket';

    # Add bucket/key value shortcut
    is test_app('App::karyn' => [qw'list b3/k3'])->stdout => "404 (Error)\n",
      'does not exist';
    is test_app('App::karyn' => [qw'add b3/k3 v3'])->stdout =>
      "204 No Content (Success)\n",
      'added';
    is test_app('App::karyn' => [qw'list b3/k3'])->stdout => "v3\n",
      'verified';
    ok test_app('App::karyn' => [qw'delete -b b3']), 'clear bucket';
};


subtest 'show keys' => sub {

    # show key value aliases
    is test_app('App::karyn' => [qw/list --bucket b1 --key k1/])->stdout =>
      "v1\n";
    is test_app('App::karyn' => [qw/list -b b1 -k k1/])->stdout => "v1\n";
    is test_app('App::karyn' => [qw|list b1/k1|])->stdout       => "v1\n";

    # Not found
    is test_app('App::karyn' => [qw|list doesnot/exist|])->stdout =>
      "404 (Error)\n";

    # List all keys in bucket
    is test_app('App::karyn' => [qw|list --bucket b1|])->stdout => "k1\n";
    is test_app('App::karyn' => [qw|list b1|])->stdout          => "k1\n";

    # Search all buckets for matching key
    like test_app('App::karyn' => [qw|list --bucket _ --key k1|])->stdout =>
      qr/k1/;
    like test_app('App::karyn' => [qw|list --key k1|])->stdout => qr/k1/;

    # Dump JSON as perl structure
    is test_app('App::karyn' => [qw|add b4/k4 {"json":"structure"}|])
      ->stdout => "204 No Content (Success)\n",
      'added';
    like test_app('App::karyn' => [qw'list b4/k4 --perl'])->stdout =>
      qr/{\s+json\s+=>\s+"structure"\s+}/,
      'pp json';
    ok test_app('App::karyn' => [qw'delete -b b4']), 'clear bucket';
};

subtest 'delete keys' => sub {

    # Delete keys
    is test_app('App::karyn' => [qw'delete --bucket b1 --key k1'])->stdout =>
      "Deleted b1/k1\n",
      'deleted';
    is test_app('App::karyn' => [qw'delete --bucket b1 --key k1'])->stdout =>
      "404 (Error)\n",
      'not found';
    is test_app('App::karyn' => [qw'list b1/k1'])->stdout => "404 (Error)\n",
      'verified';

    is test_app('App::karyn' => [qw'delete b2/k2'])->stdout =>
      "Deleted b2/k2\n",
      'deleted';
    is test_app('App::karyn' => [qw'list b2/k2'])->stdout => "404 (Error)\n",
      'verified';

    # Delete all keys in bucket
    is test_app('App::karyn' => [qw'add b1/k1 --value v1'])->stdout =>
      "204 No Content (Success)\n",
      'added';
    is test_app('App::karyn' => [qw'delete --bucket b1'])->stdout =>
      "Deleted b1/k1\n",
      'deleted';
    is test_app('App::karyn' => [qw'list b1/k1'])->stdout => "404 (Error)\n",
      'verified';

    # Delete all keys in bucket shortcut
    is test_app('App::karyn' => [qw'add b1/k1 --value v1'])->stdout =>
      "204 No Content (Success)\n",
      'added';
    is test_app('App::karyn' => [qw'delete b1'])->stdout => "Deleted b1/k1\n",
      'deleted';
    is test_app('App::karyn' => [qw'list b1/k1'])->stdout => "404 (Error)\n",
      'verified';
};

done_testing;
