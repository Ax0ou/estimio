require "test_helper"

class TranscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get transcriptions_create_url
    assert_response :success
  end
end
