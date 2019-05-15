FROM ruby:2.5.3
MAINTAINER apply for legal aid team
ENV RAILS_ENV production
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

EXPOSE 3000

RUN adduser --disabled-password apply -u 1001 && \
    chown -R apply:apply /myapp

USER 1001

CMD ["docker/run"]
