# Reelist

Reelist is a Ruby on Rails portfolio application for building a personal cinema library. Users can create film collections, import real movie data from TMDB, choose cinematic cover images from Pexels, rate films, read community comments and ask the app for a movie-night recommendation.

The project started as a Rails watch-list exercise and has been reworked into a more complete product-oriented app suitable for a recruiter review.

## Product focus

Reelist is designed around two simple user flows:

1. **Collections** — create curated lists such as “Science Fiction”, “Mind Benders” or “Critics Night”.
2. **Movie Night** — select a mood, duration and optional genre to get a recommendation powered by TMDB.

## Key features

- User authentication with Devise.
- User-owned collections.
- TMDB movie search and import.
- TMDB-powered movie-night recommendations.
- Pexels cover image picker for collection visuals.
- Pexels video background on the home hero.
- Film-level ratings and comments from app users.
- Collapsible community comments under each film.
- Responsive cinema-inspired UI with mobile bottom navigation.
- Demo seed data for deployment reviews.
- Production-ready Heroku configuration.

## Tech stack

- Ruby `3.3.5`
- Rails `8.1.x`
- PostgreSQL
- Devise
- Turbo / Stimulus
- SassC / Bootstrap
- TMDB API
- Pexels API
- Heroku / Puma

## Environment variables

Create a local `.env` file from the example file:

```bash
cp .env.example .env
```

Required values:

```env
TMDB_API_TOKEN=your_tmdb_read_access_token
PEXELS_API_KEY=your_pexels_api_key
```

Optional values for seeded demo access:

```env
DEMO_USER_EMAIL=demo@reelist.app
DEMO_USER_PASSWORD=password
```

For Heroku, the same values must be configured as Heroku config vars.

## Local setup

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Open:

```text
http://localhost:3000
```

Default seeded account:

```text
Email: demo@reelist.app
Password: password
```

## Quality checks

```bash
bin/rails test
bundle exec brakeman --no-pager
bundle exec bundle-audit check --update
bundle exec rubocop
```

## Heroku deployment

The repository includes a `Procfile` for Puma and an `app.json` manifest documenting the required config vars.

Typical deployment flow:

```bash
heroku login
heroku create your-reelist-app-name
heroku addons:create heroku-postgresql:essential-0 -a your-reelist-app-name
heroku config:set \
  APP_HOST=your-reelist-app-name.herokuapp.com \
  SECRET_KEY_BASE=$(bin/rails secret) \
  TMDB_API_TOKEN=your_tmdb_read_access_token \
  PEXELS_API_KEY=your_pexels_api_key \
  DEMO_USER_EMAIL=demo@reelist.app \
  DEMO_USER_PASSWORD=password \
  -a your-reelist-app-name

git push heroku portfolio-improvements:main
heroku run rails db:migrate db:seed -a your-reelist-app-name
heroku open -a your-reelist-app-name
```

## Recruiter review notes

This app demonstrates:

- Rails MVC fundamentals with scoped, user-owned resources.
- External API integration with error handling and environment-based credentials.
- Data modeling for many-to-many movie collections and user-specific reviews.
- Responsive product UI rather than scaffold-style pages.
- Production deployment awareness: PostgreSQL, Puma, environment variables and Heroku process boot.

## Credits

- Movie metadata: [TMDB](https://www.themoviedb.org/)
- Images and video: [Pexels](https://www.pexels.com/)

This product uses the TMDB API but is not endorsed or certified by TMDB.
