# frozen_string_literal: true

class AuthController < ApplicationController
  def signin
    unless params[:code]
      render nothing: true, status: :bad_request
      return
    end

    resp = lookup_auth_code(params[:code])
    unless resp
      redirect_to :root
      return
    end

    ActiveRecord::Base.transaction do
      user = User.where(subscriber: resp.id_token[:sub]).first
      if user.nil?
        user = User.create(subscriber: resp.id_token[:sub],
                           email: resp.id_token[:email])
      end

      cognito_session = CognitoSession.create(user: user,
                                              expire_time: resp.id_token[:exp],
                                              issued_time: resp.id_token[:auth_time],
                                              audience: resp.id_token[:aud],
                                              refresh_token: resp.refresh_token)
      session[:cognito_session_id] = cognito_session.id
    end

    redirect_to :root
  end

  def signout
    if cognito_session_id = session[:cognito_session_id]
      cognito_session = begin
                          CognitoSession.find(cognito_session_id)
                        rescue StandardError
                          nil
                        end
      cognito_session&.destroy
      session.delete(:cognito_session_id)
    end

    redirect_to '/'
  end

  def lookup_auth_code(code)
    client = new_cognito_client
    client.get_pool_tokens(code)
  end
end
