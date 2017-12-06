# SpaceX Launches Tooter

Toots the next upcoming SpaceX launch as listed here: https://www.reddit.com/r/spacex/wiki/launches/manifest

## Setup

1. You need Ruby (probably 2.3 or higher).

2. Install gems:

   ```
   gem install bundler
   bundle install
   ```

3. Create an account on Mastodon and create an OAuth App. Copy "Your access token" which is your bearer token for use in the next command...

## Usage

```
TOKEN=abc123 ruby tooter.rb
```

## Testing

```
DEBUG=true ruby tooter.rb
```

The script will just print out the message to the screen.
