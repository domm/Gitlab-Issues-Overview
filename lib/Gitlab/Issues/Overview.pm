package Gitlab::Issues::Overview;
use strict;
use warnings;
use 5.024;
use base qw(Class::Accessor::Fast);

# ABSTRACT: List issues over all projects by multiple labels

our $VERSION = "0.900";

use Encode;
use Path::Tiny;
use JSON::MaybeXS qw(encode_json decode_json);

__PACKAGE__->mk_ro_accessors(qw(gitlab_client projects_file));

sub app {
    my $self = shift;

    my $projects  = $self->get_projects;
    my $app_ident = __PACKAGE__ . ' ' . $VERSION;
    my $app       = sub {
        my $env = shift;

        my $html = qq{<!doctype html><html>
<head><meta charset='utf-8'><title>$app_ident</title><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"><link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.3/css/bootstrap.min.css" integrity="sha384-Zug+QiDoJOrZ5t4lssLdxGhVrurbmBWopoEl+M6BdEfwnCJZtKxi1KgxUyJq13dy" crossorigin="anonymous"></head>
<body>
<table class="table table-striped table-hover table-sm">
<thead class="thead-dark"><tr><th>Project</th><th>Issue</th><th>Title</th><th>Labels</th><th>Assignee</th><th>Milestone</th></tr></thead>
<tbody>};

        my %seen;
        foreach my $l ( 'Doing', 'showstopper', 'critical', 'To do', 'To Do','todo', 'bug' ) {
            my $issues = $self->gitlab_client->paginator('global_issues',
                {   state  => 'opened',
                    scope  => 'all',
                    labels => $l,
                }
            )->all;
            foreach my $issue (@$issues) {
                next if $seen{ $issue->{id} }++;

                my $assignee = $issue->{assignees}[0] || $issue->{assignee};
                my @row = (
                    $projects->{ $issue->{project_id} }
                        || $issue->{project_id},
                    '#' . $issue->{iid},
                    sprintf(
                        '<a href="%s">%s</a>',
                        $issue->{web_url}, $issue->{title}
                    ),
                    join( ', ', sort @{ $issue->{labels} } ),
                    (   $assignee
                        ? sprintf(
                            '<img src="%s" title="%s" width="32" height="32"/>',
                            $assignee->{avatar_url},
                            $assignee->{name}
                            )
                        : 'n.a.'
                    ),
                    ( $issue->{milestone}{title} || 'no milestone' ),
                );
                $html .= '<tr>'
                    . ( join( '', map {"<td>$_</td>"} @row ) )
                    . "</tr>\n";
            }
        }

        $html .=
            qq{</tbody></table><footer>Powered by $app_ident</footer></body></html>};
        return [
            200,
            [ 'Content-Type' => 'text/html; charset=utf-8' ],
            [ encode_utf8($html) ]
        ];
    };

    return $app;
}

sub get_projects {
    my $self = shift;

    if ( -e $self->projects_file ) {
        return decode_json( path( $self->projects_file )->slurp );
    }
    else {
        my $projects = {
            map { $_->{id} => $_->{name_with_namespace} } @{
                $self->gitlab_client->paginator( 'projects',
                    { archived => 0, } )->all
            }
        };
        path( $self->projects_file )->spew( encode_json($projects) );
        return $projects;
    }
}

1;
