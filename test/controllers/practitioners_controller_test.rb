require "test_helper"

class PractitionersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:desk)
  end

  test "updates working hours" do
    patch practitioner_path(practitioners(:ben)), params: { practitioner: {
      day_starts_at_hour: 7, day_ends_at_hour: 15, works_weekends: "1"
    } }

    assert_redirected_to practitioner_path(practitioners(:ben))
    ben = practitioners(:ben).reload
    assert_equal [ 7, 15, true ], [ ben.day_starts_at_hour, ben.day_ends_at_hour, ben.works_weekends ]
  end

  test "won't save hours that end before they start" do
    patch practitioner_path(practitioners(:ben)), params: { practitioner: {
      day_starts_at_hour: 15, day_ends_at_hour: 9
    } }

    assert_response 422
  end
end
