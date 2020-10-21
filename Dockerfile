FROM ruby:2.6.6
MAINTAINER apply for legal aid team
ENV RAILS_ENV production
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN gem install bundler -v 2.0.2 \
&& bundle config --global without test:development \
&& bundle config build.nokogiri --use-system-libraries \
&& bundle install

COPY . /myapp

EXPOSE 3000

RUN adduser --disabled-password apply -u 1001 && \
    chown -R apply:apply /myapp

# expect ping environment variables
ARG BUILD_DATE
ARG BUILD_TAG
ARG APP_BRANCH
# set ping environment variables
ENV BUILD_DATE=${BUILD_DATE}
ENV BUILD_TAG=${BUILD_TAG}
ENV APP_BRANCH=${APP_BRANCH}
# allow public files to be served
ENV RAILS_SERVE_STATIC_FILES true

USER 1001

CMD ["docker/run"]
