require "test_helper"

class PdfsControllerTest < ActionDispatch::IntegrationTest
  test "should get manufacturing_instruction" do
    get pdfs_manufacturing_instruction_url
    assert_response :success
  end

  test "should get distribution_instruction" do
    get pdfs_distribution_instruction_url
    assert_response :success
  end
end
