# frozen_string_literal: true

require 'cognito_urls'

class CognitoJwtKeysProvider
  class << self
    @jwt_keys = nil

    def init(pool_id)
      resp = Excon.get(key_url(pool_id))
      keys = JSON.parse(resp.body)
      keymap = Hash[keys['keys'].map do |key|
                      [key['kid'], JSON::JWK.new(key)]
                    end]
      @jwt_keys = CognitoJwtKeys.new(keymap)
    end

    def keys
      @jwt_keys
    end

    def key_url(pool_id)
      CognitoUrls.jwks_uri(pool_id)
    end
  end
end

class CognitoJwtKeys
  def initialize(keymap)
    @keys = keymap
  end

  def get(key_id, alg = 'RS256')
    key = @keys[key_id]

    raise "No such JWK `#{key_id}`: #{@keys.keys}" unless key

    unless key[:alg] == alg
      raise "Algorithm not compatible #{key[:alg]} != #{alg}"
    end

    key
  end
end
