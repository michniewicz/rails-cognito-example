# frozen_string_literal: true

require 'cognito_jwt_keys'
require 'cognito_urls'

unless ENV['AWS_COGNITO_DOMAIN'].blank?
  CognitoUrls.init(ENV['AWS_COGNITO_DOMAIN'],
                   ENV['AWS_COGNITO_REGION'])

  CognitoJwtKeysProvider.init(ENV['AWS_COGNITO_POOL_ID'])
end
