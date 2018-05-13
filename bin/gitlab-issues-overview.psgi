#!/usr/env/perl
use strict;
use warnings;
use lib('./');

use Plack;
use Gitlab::Issues::Overview;
use GitLab::API::v4;

my $client =  GitLab::API::v4->new(
    url => $ENV{GITLAB_ISSUES_OVERVIEW_API_URL},
    private_token => $ENV{GITLAB_ISSUES_OVERVIEW_PRIVATE_TOKEN},
);

return Gitlab::Issues::Overview->new({
    gitlab_client => $client,
    projects_file => $ENV{GITLAB_ISSUES_OVERVIEW_PROJECTS_FILE} || './projects.json',
})->app;

