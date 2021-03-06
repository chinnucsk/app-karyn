package App::karyn::Command::Delete;

use strict;
use warnings;

use App::karyn -command;

sub opt_spec {
    return (
        ['bucket|b=s' => 'Bucket name', {default => '_'}],
        ['key|k=s'    => 'Key name',    {default => '_'}],
    );
}

sub abstract   {'Delete keys from buckets'}
sub usage_desc {'karyn delete --bucket name --key name'}

sub validate_args {
    my ($self, $opt, $args) = @_;

    $self->usage_error('Bucket and/or key required')
      if !$opt->bucket
          and !$opt->key;
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $bucket = $opt->bucket;
    my $key    = $opt->key;

    my $tiny = $self->app->tiny;

    if (    $bucket eq '_'
        and $key eq '_'
        and @$args
        and $args->[0] =~ /(.+?)(?:\/(.+))?$/)
    {
        $bucket = $1;
        $key    = $2 if $2;
    }

    # Delete all keys in bucket
    if ($bucket ne '_' and $key eq '_') {
        for ($tiny->get($bucket)->delete_keys) {
            print "Deleted $bucket/$_\n";
        }
    }

    # Delete bucket key/value
    elsif ($bucket ne '_' and $key ne '_') {
        my $obj = $tiny->get($bucket => $key);
        my $code = $obj ? $obj->client->tx->res->code : $@;
        print "$code (Error)\n" and return if $code != 200;

        $obj->delete;
        print "Deleted $bucket/" . $obj->key . "\n";
    }
}

1;

=head1 NAME

App::karyn::Command::Delete

=head1 DESCRIPTION

Removes key/values to Riak

=head1 USAGE

See L<App::karyn>

=head1 METHODS

See L<App::Cmd>

=cut
