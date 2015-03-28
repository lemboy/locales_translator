require 'test_helper'

class TranslatorControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get upload_file" do
    get :upload_file
    assert_response :success
  end

  test "should get save_file" do
    get :save_file
    assert_response :success
  end

end
