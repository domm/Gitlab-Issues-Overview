FROM perl:5.28

RUN adduser --disabled-password --disabled-login --gecos "perl user" --home /home/perl perl

COPY cpanfile .
COPY bin .
COPY lib .

RUN cpanm -n --installdeps .

COPY . /home/Gitlab-Issues-Overview

USER perl
WORKDIR /home/Gitlab-Issues-Overview
ENTRYPOINT [ "plackup", "-Ilib", "--no-default-middleware", "-s", "Starman", "--workers", "2", "/home/Gitlab-Issues-Overview/bin/gitlab-issues-overview.psgi" ]

