# encoding: utf-8
require 'test_helper'

class Front::SessionsControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

end
