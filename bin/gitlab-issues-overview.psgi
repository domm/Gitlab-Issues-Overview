#!/usr/env/perl
use strict;
use warnings;
use lib('./');

use Plack;
use Gitlab::Issues::Overview;
use GitLab::API::v4;

my $client =  GitLab::API::v4->new(
    url => $ENV{GITLAB_API_URL},
    private_token => $ENV{GITLAB_PRIVATE_TOKEN},
);

return Gitlab::Issues::Overview->new({
    gitlab_client => $client,
    projects_file => $ENV{PROJECTS_FILE} || './projects.json',
    labels        => [split(/[ ,]/,$ENV{LABELS} || 'todo')] ,
})->app;

