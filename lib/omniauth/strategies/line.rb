require 'omniauth-oauth2'
require 'json'

module OmniAuth
  module Strategies
    class Line < OmniAuth::Strategies::OAuth2
      option :name, 'line'
      option :scope, 'profile openid email'

      option :client_options, {
        site: 'https://access.line.me',
        authorize_url: '/oauth2/v2.1/authorize',
        token_url: '/oauth2/v2.1/token'
      }

      # host changed
      def callback_phase
        options[:client_options][:site] = 'https://api.line.me'
        super
      end

      # Correct redirect_uri_mismatch issues related to callback_uri through path match.
      # NOTE If we're using code from the signed request then FB sets the redirect_uri to '' during the authorize
      #      phase and it must match during the access_token phase:
      #      https://github.com/facebook/facebook-php-sdk/blob/master/src/base_facebook.php#L477
      def callback_url
        if @authorization_code_from_signed_request_in_cookie
          ''
        else
          # callback url ignorance issue from https://github.com/intridea/omniauth-oauth2/commit/85fdbe117c2a4400d001a6368cc359d88f40abc7
          options[:callback_url] || (full_host + script_name + callback_path)
        end
      end

      uid { raw_info['userId'] }

      info do
        {
          name:        raw_info['displayName'],
          image:       raw_info['pictureUrl'],
          description: raw_info['statusMessage'],
          email: email
        }
      end

      # Require: Access token with PROFILE permission issued.
      def raw_info
        @id_token = access_token.params["id_token"]
        @raw_info ||= JSON.load(access_token.get('v2/profile').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      def email
        uri = URI.parse("https://api.line.me/oauth2/v2.1/verify")
        request = Net::HTTP::Post.new(uri)
        request.set_form_data(
          "client_id" => client.id,
          "id_token" => @id_token
        )

        req_options = {
          use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        JSON.parse(response.body)["email"]
      end
    end
  end
end
