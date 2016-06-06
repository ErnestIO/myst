lint:
	jruby -S bundle exec rubocop

cover:
	COVERAGE=true MIN_COVERAGE=0 bundle exec rspec -c -f d spec

deps:
	jruby -S bundle install

test:
	jruby -S bundle exec rspec spec
