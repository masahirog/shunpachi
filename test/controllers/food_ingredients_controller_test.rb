require "test_helper"

class FoodIngredientsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get food_ingredients_index_url
    assert_response :success
  end

  test "should get new" do
    get food_ingredients_new_url
    assert_response :success
  end

  test "should get edit" do
    get food_ingredients_edit_url
    assert_response :success
  end

  test "should get _form" do
    get food_ingredients__form_url
    assert_response :success
  end
end
