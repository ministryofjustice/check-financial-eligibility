INSTALL CUCUMBER
-----------------

add 'gem "cucumber-rails", "~> 2.5", ">= 2.5.1", require: false' in the gemfile sections (bottom):

development
test
development, test

run `bundle install`

restart spring server

bin/spring stop
bin/spring

Execute tests using:

bundle exec cucumber
