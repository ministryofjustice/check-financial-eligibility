FROM ruby:2.7.2
MAINTAINER apply for legal aid team
ENV RAILS_ENV production
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y nodejs yarn postgresql-client
RUN mkdir /myapp
WORKDIR /myapp

RUN adduser --disabled-password apply -u 1001

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN gem install bundler -v 2.0.2 \
&& bundle config --global without test:development \
&& bundle config build.nokogiri --use-system-libraries \
&& bundle install

COPY . /myapp

RUN yarn --prod

RUN bundle exec rake assets:precompile SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here

EXPOSE 3000

RUN chown -R apply:apply /myapp

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
