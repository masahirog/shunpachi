require "test_helper"

class FoodAdditivesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get food_additives_index_url
    assert_response :success
  end

  test "should get new" do
    get food_additives_new_url
    assert_response :success
  end

  test "should get edit" do
    get food_additives_edit_url
    assert_response :success
  end

  test "should get _form" do
    get food_additives__form_url
    assert_response :success
  end
end
