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

      uid { raw_info['userId'] }

      info do
        {
            name:        raw_info['displayName'],
            image:       raw_info['pictureUrl'],
            description: raw_info['statusMessage'],
            email:       id_token_payload['email']
        }
      end

      # Require: Access token with PROFILE permission issued.
      def raw_info
        @raw_info ||= JSON.load(access_token.get('v2/profile').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      # https://developers.line.biz/ja/reference/social-api/#verify-id-token
      def id_token_payload
        return {} if id_token.blank?

        response = Faraday.post('https://api.line.me/oauth2/v2.1/verify', "id_token=#{id_token}&client_id=#{client.id}")
        JSON.parse(response.body)
      end

      def id_token
        @id_token ||= if access_token.present?
                        access_token.params['id_token']
                      end
      end
    end
  end
end
