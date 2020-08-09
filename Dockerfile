FROM ruby:2.6.6-alpine
RUN apk --update add build-base tzdata postgresql-dev postgresql-client libxslt-dev libxml2-dev

ENV APP_PATH /app
RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH

COPY Gemfile Gemfile.lock $APP_PATH/
RUN gem install bundler:2.1.4
RUN bundle install
COPY . $APP_PATH

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]