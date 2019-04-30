# Base image
FROM ruby:2.5.3

ENV HOME /home/rails/webapp

# Install PGsql dependencies and js engine
RUN apt-get update -qq && apt-get install 

WORKDIR $HOME

# Install gems
ADD Gemfile* $HOME/
RUN bundle install

# Add the app code
ADD . $HOME

# Default command
CMD ["rails", "server", "--binding", "0.0.0.0”]
