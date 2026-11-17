# OmniAuth Line

This gem contains the LINE OAuth2 Strategy for OmniAuth (`>= 2.0`).

Supports the OpenID Connect Web Login (LINE Login v2.1). Read the LINE Developers docs for more details: https://developers.line.biz/en/docs/line-login/integrate-line-login/

## Using This Strategy

First start by adding this gem to your Gemfile:

```ruby
gem 'omniauth-line'
# For Rails apps with OmniAuth 2.0+, also add CSRF protection:
gem 'omniauth-rails_csrf_protection'
```

Next, tell OmniAuth about this provider. For a Rails app, your `config/initializers/omniauth.rb` file should look like this:

```ruby
# PROFILE permission required!!
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line, ENV['LINE_CHANNEL_ID'], ENV['LINE_CHANNEL_SECRET']
end
```

### Initiating Login (OmniAuth 2.0+)

In OmniAuth 2.0+, the request phase requires an HTTP `POST` request with a CSRF token. In Rails, use `button_to` (or `form_with`) with `data: { turbo: false }`:

```erb
<%= button_to 'Log in with LINE', '/auth/line', method: :post, data: { turbo: false } %>
```

### Requesting Email Address

If your LINE Login channel has permission to obtain the user's email address, include `email` in the `scope` option:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line, ENV['LINE_CHANNEL_ID'], ENV['LINE_CHANNEL_SECRET'],
    scope: 'profile openid email'
end
```

When an `id_token` is returned by LINE, `omniauth-line` verifies it via LINE's `/oauth2/v2.1/verify` endpoint and sets `info[:email]`.

### Adding a LINE Official Account as a Friend (`bot_prompt`)

To display an option to add a linked LINE Official Account as a friend during login, pass `bot_prompt` (`normal` or `aggressive`) via `authorize_params`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line, ENV['LINE_CHANNEL_ID'], ENV['LINE_CHANNEL_SECRET'],
    authorize_params: {
      bot_prompt: 'aggressive' # or 'normal'
    }
end
```

See the [LINE documentation on linking a LINE Official Account](https://developers.line.biz/en/docs/line-login/link-a-bot/) for details.

## Authentication Hash

An example auth hash available in `request.env['omniauth.auth']`:

```ruby
{
  :provider => "line",
  :uid => "a123b4....",
  :info => {
    :name => "yamada tarou",
    :image => "http://dl.profile.line.naver.jp/xxxxx",
    :description => "breakfast now.",
    :email => "tarou@example.com" # Present when 'email' scope is granted
  },
  :credentials => {
    :token => "a1b2c3d4...", # The OAuth 2.0 access token
    :refresh_token => "e5f6g7...",
    :expires_at => 1700000000,
    :expires => true
  },
  :extra => {
    "raw_info" => {
      "userId" => "a123b4....",
      "displayName" => "yamada tarou",
      "pictureUrl" => "http://dl.profile.line.naver.jp/xxxxx",
      "statusMessage" => "breakfast now."
    }
  }
}
```

## Supported Rubies

OmniAuth Line is tested under Ruby 3.1, 3.2, 3.3, and 3.4.
