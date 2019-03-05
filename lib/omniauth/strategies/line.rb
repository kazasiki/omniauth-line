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

      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end

      uid { raw_info['userId'] }

      info do
        {
          name:        raw_info['displayName'],
          image:       raw_info['pictureUrl'],
          description: raw_info['statusMessage'],
          email:    JWT.decode(access_token.params["id_token"], nil, false, { algorithm: 'HS256' })[0]["email"]
        }
      end

      # Require: Access token with PROFILE permission issued.
      def raw_info
        @raw_info ||= JSON.load(access_token.get('v2/profile').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      # def custom_build_access_token
      #   access_token = get_access_token(request)

      #   # TODO: access_tokenを有効か確認する
      #   # verify_hd(access_token)
      #   access_token
      # end
      # alias build_access_token custom_build_access_token

      private

      # def get_access_token(request)
      #   verifier = request.params['code']
      #   client.auth_code.get_token(verifier, get_token_options(callback_url), deep_symbolize(options.auth_token_params))

      #   if request.xhr? && request.params['code']
      #     verifier = request.params['code']
      #     redirect_uri = request.params['redirect_uri'] || 'postmessage'
      #     client.auth_code.get_token(verifier, get_token_options(redirect_uri), deep_symbolize(options.auth_token_params || {}))
      #   elsif request.params['code'] && request.params['redirect_uri']
      #     verifier = request.params['code']
      #     redirect_uri = request.params['redirect_uri']
      #     client.auth_code.get_token(verifier, get_token_options(redirect_uri), deep_symbolize(options.auth_token_params || {}))
      #   elsif verify_token(request.params['access_token'])
      #     ::OAuth2::AccessToken.from_hash(client, request.params.dup)
      #   else
      #     verifier = request.params['code']
      #     client.auth_code.get_token(verifier, get_token_options(callback_url), deep_symbolize(options.auth_token_params))
      #   end
      # end

    end
  end
end
