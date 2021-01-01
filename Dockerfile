FROM ruby:2.5.3
ENV LANG C.UTF-8
RUN apt-get update -qq && \
    apt-get install -y build-essential \
                       libpq-dev \
                       nodejs \
                       imagemagick \
                       cron \
                       vim \
                       curl
RUN mkdir /my_app
ENV APP_ROOT /my_app
WORKDIR $APP_ROOT

ADD ./Gemfile $APP_ROOT/Gemfile
ADD ./Gemfile.lock $APP_ROOT/Gemfile.lock

RUN bundle install
ADD . $APP_ROOT
