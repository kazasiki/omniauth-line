require 'omniauth-oauth2'
require 'json'

module OmniAuth
  module Strategies
    class Line < OmniAuth::Strategies::OAuth2
      option :name, 'line'

      option :client_options, {:site  => 'https://access.line.me',
                               :authorize_url => '/dialog/oauth/weblogin',
                               :token_url     => '/v1/oauth/accessToken',
                               :proxy => ENV['http_proxy'] ? URI(ENV['http_proxy']) : nil}

      # host changed
      def callback_phase
        options[:client_options][:site] = 'https://api.line.me'
        super
      end

      uid { raw_info['mid'] }

      info do
        {
          name:        raw_info['displayName'],
          image:       raw_info['pictureUrl'],
          description: raw_info['statusMessage']
        }
      end

      # Require: Access token with PROFILE permission issued.
      def raw_info
        @raw_info ||= JSON.load(access_token.get('v1/profile').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

    end
  end
end
