ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  def sign_in_as(user, password: "password")
    post session_path, params: { email: user.email, password: password }
  end
end
