## Running in Docker

```
docker-compose build
docker-compose run web bundle exec rake db:create
docker-compose run web bundle exec rake db:migrate
docker-compose up
```

To run specs:

```
docker-compose run web bundle exec rspec
```
