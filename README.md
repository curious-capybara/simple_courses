## API

| HTTP verb | Endpoint | Params | Notes |
|-----------|----------|--------|-------|
| POST      | /users   | `email` (string, required) | Create new user
| DELETE    | /users/:id || Deletes user with given id
| POST      | /courses | `name` (string, required) | Creates new course
| DELETE    | /courses/:id || Deletes a course with given id
| GET       | /courses || Lists courses and number of people enrolled
| POST      | /courses/:id/enrollments | `user_id` (integer, required) | Enroll user with given id to the course
| DELETE    | /courses/:id/enrollments/:user_id || Withdraws user enrollment from the course

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
