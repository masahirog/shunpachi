require "test_helper"

class MaterialsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get materials_index_url
    assert_response :success
  end

  test "should get new" do
    get materials_new_url
    assert_response :success
  end

  test "should get edit" do
    get materials_edit_url
    assert_response :success
  end

  test "should get _form" do
    get materials__form_url
    assert_response :success
  end
end
