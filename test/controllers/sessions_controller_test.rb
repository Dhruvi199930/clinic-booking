require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "pages need a login" do
    get appointments_path

    assert_redirected_to new_session_path
  end

  test "logs in with the right password" do
    sign_in_as users(:desk)

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "wrong password" do
    sign_in_as users(:desk), password: "nope"

    assert_response 422
    assert_select ".errors", /Wrong email or password/
  end

  test "logs out" do
    sign_in_as users(:desk)
    delete session_path

    get appointments_path
    assert_redirected_to new_session_path
  end
end
