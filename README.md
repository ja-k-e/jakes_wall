# Jake's Wall

Make your Tweet appear on Jake's wall.

# Setup

- clone
- `bundle install`
- `rake db:migrate`
- create `config/local_env.yml`
  - add `TWITTER_KEY: xxxxxxxxxxxxxxxxx`
  - add `TWITTER_SECRET: xxxxxxxxxxxxxxxxx`
- modify search term at [`wall_controller.rb:5`](https://github.com/jakealbaugh/jakes_wall/blob/master/app/controllers/wall_controller.rb#L5)
- `rails s`
- visit [localhost:3000](http://localhost:3000)


You can request data with a static front end app similarly to [jakes_wall_reader](https://github.com/jakealbaugh/jakes_wall_reader).
