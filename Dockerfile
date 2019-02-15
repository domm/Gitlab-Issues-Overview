FROM perl:5.28

RUN apt-get update && apt-get update && apt-get install -y dumb-init
RUN adduser --disabled-password --disabled-login --gecos "perl user" --home /home/perl perl

ADD lib .
ADD bin .
ADD cpanfile .

RUN cpanm -n --installdeps .

COPY . /home/Gitlab-Issues-Overview

USER perl
WORKDIR /home/Gitlab-Issues-Overview
ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]
CMD [ "plackup", "-Ilib", "--no-default-middleware", "-s", "Starman", "--workers", "2", "/home/Gitlab-Issues-Overview/bin/gitlab-issues-overview.psgi" ]

