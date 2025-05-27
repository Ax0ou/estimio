require "test_helper"

class AiMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get ai_messages_new_url
    assert_response :success
  end

  test "should get create" do
    get ai_messages_create_url
    assert_response :success
  end
end
