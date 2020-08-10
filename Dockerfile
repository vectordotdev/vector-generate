FROM ruby:2.7

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL C.UTF-8

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle install

WORKDIR /usr/app

CMD ["/usr/app/main.rb"]