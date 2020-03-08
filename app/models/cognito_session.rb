# frozen_string_literal: true

class CognitoSession < ApplicationRecord
  belongs_to :user
end
