# frozen_string_literal: true

class User < ApplicationRecord
  has_many :cognito_sessions
end
