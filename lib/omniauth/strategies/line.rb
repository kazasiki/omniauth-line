require 'omniauth-oauth2'
require 'json'
require 'jwt'

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

      uid { raw_info['userId'] }

      info do
        {
          name:        raw_info['displayName'],
          image:       raw_info['pictureUrl'],
          description: raw_info['statusMessage'],
          id_token:    JWT.decode(access_token.params["id_token"], nil, false, { algorithm: 'HS256' })[0]["email"]
        }
      end

      # Require: Access token with PROFILE permission issued.
      def raw_info
        @raw_info ||= JSON.load(access_token.get('v2/profile').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

    end
  end
end
