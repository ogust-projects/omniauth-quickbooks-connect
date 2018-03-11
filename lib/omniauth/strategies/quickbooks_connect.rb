require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class QuickbooksConnect < OmniAuth::Strategies::OAuth2
      option :name, :quickbooks_connect

      option :client_options, {
        :access_token_path  => "/oauth/v1/get_access_token",
        :authorize_url      => "https://appcenter.intuit.com/Connect/Begin",
        :request_token_path => "/oauth/v1/get_request_token",
:site => "https://oauth.intuit.com",
      }

      option :provider_ignores_state, true


     
      uid { access_token.params['realmId'] }



      info do
        {
          :email => raw_info[:email],
          :organisation_name => raw_info[:organisation_name],
          :given_name => raw_info['given_name'],
          :family_name => raw_info['family_name'],
        }
      end

      def raw_info
        @raw_info ||= deep_symbolize(access_token.params)
      end

      extra do
        e = {
          :raw_info => raw_info
        }
        #e[:extra_info] = extra_info unless skip_info?

        e
      end


      def redirect_params
        if options.key?(:callback_path) || OmniAuth.config.full_host
          {:redirect_uri => callback_url}
        else
          {}
        end
      end

      # NOTE: We call redirect_params AFTER super in these methods intentionally
      # the OAuth2 strategy uses the authorize_params and token_params methods
      # to set up some state for testing that we need in redirect_params

      def authorize_params
        params = super
        params = params.merge(request.params) unless OmniAuth.config.test_mode
        redirect_params.merge(params)
      end

      def request_phase
        redirect client.auth_code.authorize_url(authorize_params)
      end

      # Required for omniauth-oauth2 >= 1.4
      # https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
