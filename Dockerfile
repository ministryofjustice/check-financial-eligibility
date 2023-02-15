FROM ruby:3.1.2-alpine3.16 as builder

ENV RAILS_ENV production

RUN set -ex

RUN apk --no-cache add build-base \
                       postgresql-dev

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN gem update --system
RUN bundle config --local without test:development && bundle install


FROM ruby:3.1.2-alpine3.16
RUN apk --no-cache add postgresql-client

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY . /myapp

WORKDIR /myapp

EXPOSE 3000

RUN adduser --disabled-password apply -u 1001
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
