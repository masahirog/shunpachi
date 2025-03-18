function onLoad() {
  material_select2();
  $('.add_material_fields').on('click',function(){
    setTimeout(function(){
      material_select2();
    },5);
  });

  $(document).on('cocoon:after-remove', function(e, removed_item) {
    cal_cost_price();
    cal_food_ingredient();
  });


  function material_select2(){
    $(".material_select2").select2({
      width: "100%",
      placeholder: "食材を検索",
      allowClear: true,
      ajax: {
        url: "/materials/search",
        dataType: "json",
        delay: 250,
        data: function (params) {
          return {
            q: params.term
          };
        },
        processResults: function (data) {
          return {
            results: data.map(function (material) {
              return { id: material.id, text: material.name };
            })
          };
        },
        cache: true
      },
      minimumInputLength: 1
    }).on('select2:select', function(e) {
      var materialId = e.params.data.id;
      var $row = $(this).closest('tr.nested-fields');
      $.ajax({
        url: `/materials/${materialId}/get_details`,
        dataType: 'json',
        success: function(data) {
          $row.find('.material_unit').text(' ' + data.unit);
          $row.find('.recipe_unit_gram_quantity').val(data.recipe_unit_gram_quantity);
          $row.find('.unit_cost_price_text').text(data.recipe_unit_price);
          $row.find('.unit_cost_price').val(data.recipe_unit_price);
          cal_gram_quantity($row);
          if (data.food_ingredient) {
            var foodIngredientLink = `<a href="/food_ingredients/${data.food_ingredient.id}/edit" target="_blank" class="food-ingredient-link">${data.food_ingredient.name}</a>`;
            $row.find('.food_ingredient_a').html(foodIngredientLink);
            $row.find('.food_ingredient_info_input.unit_calorie').val(data.food_ingredient.calorie);
            $row.find('.food_ingredient_info_input.unit_protein').val(data.food_ingredient.protein);
            $row.find('.food_ingredient_info_input.unit_lipid').val(data.food_ingredient.lipid);
            $row.find('.food_ingredient_info_input.unit_carbohydrate').val(data.food_ingredient.carbohydrate);
            $row.find('.food_ingredient_info_input.unit_salt').val(data.food_ingredient.salt);
          } else {
            $row.find('.food_ingredient_a').empty();
            $row.find('.food_ingredient_info_input').val('');
          }
          cal_food_ingredient($row);
          cal_cost_price($row);
        }
      });
    }).on('select2:clear', function(e) {
      var $row = $(this).closest('tr.nested-fields');
      $row.find('.material_unit').text('');
      $row.find('.recipe_unit_gram_quantity').val('');
      $row.find('.amount_used').val('');
      $row.find('.gram_quantity').val('');
      $row.find('.cost_price').val('');
      $row.find('.unit_cost_price').val('');
      $row.find('.unit_cost_price_text').text('');
      $row.find('.food_ingredient_a').empty();
      $row.find('.food_ingredient_info_input').val('');
      cal_food_ingredient($row);
      cal_cost_price($row);
    });  
  };

  $('#menu_materials-add-point').on('change',".amount_used",function(){
    var $row = $(this).closest('tr.nested-fields');
    cal_gram_quantity($row);
    cal_food_ingredient($row);
    cal_cost_price($row);
  });
  $('#menu_materials-add-point').on('change',".gram_quantity",function(){
    var $row = $(this).closest('tr.nested-fields');
    cal_food_ingredient($row);
  });


  $('#material_recipe_unit').on('change', function() {
    var unit = $(this).find("option:selected").text(); // 選択されたoptionのテキストを取得
    $(".label-recipe_unit_price").text("1" + unit + "の税抜価格");
  });



  function cal_gram_quantity($row){
    var recipe_unit_gram_quantity = $row.find('.recipe_unit_gram_quantity').val();
    var amount_used = $row.find(".amount_used").val();
    var gram_quantity = (amount_used * recipe_unit_gram_quantity);
    $row.find(".gram_quantity").val(gram_quantity.toFixed(1));
  }

  function cal_cost_price($row){
    if ($row) {
      var amount_used = parseFloat($row.find(".amount_used").val()) || 0;
      var unit_cost_price = parseFloat($row.find(".unit_cost_price").val()) || 0;
      var cost_price = amount_used * unit_cost_price;
      $row.find(".cost_price").val(cost_price.toFixed(1));
    }
    
    var menu_cost_price = 0;
    $(".cost_price:visible").each(function(){
      var mm_cost_price = parseFloat($(this).val()) || 0;
      menu_cost_price += mm_cost_price;
    });
    $(".menu_cost_price").val(menu_cost_price.toFixed(1));
  }

  function cal_food_ingredient($row){
    if ($row) {
      var gram_quantity = parseFloat($row.find(".gram_quantity").val()) || 0;
      var unit_calorie = parseFloat($row.find('.unit_calorie').val()) || 0;
      var unit_protein = parseFloat($row.find('.unit_protein').val()) || 0;
      var unit_lipid = parseFloat($row.find('.unit_lipid').val()) || 0;
      var unit_carbohydrate = parseFloat($row.find('.unit_carbohydrate').val()) || 0;
      var unit_salt = parseFloat($row.find('.unit_salt').val()) || 0;
      $row.find(".gram_calorie").val((gram_quantity * unit_calorie).toFixed(1));
      $row.find(".gram_protein").val((gram_quantity * unit_protein).toFixed(1));
      $row.find(".gram_lipid").val((gram_quantity * unit_lipid).toFixed(1));
      $row.find(".gram_carbohydrate").val((gram_quantity * unit_carbohydrate).toFixed(1));
      $row.find(".gram_salt").val((gram_quantity * unit_salt).toFixed(1));
    }
    
    var menu_calorie = 0;
    var menu_protein = 0;
    var menu_lipid = 0;
    var menu_carbohydrate = 0;
    var menu_salt = 0;

    $(".nested-fields:visible").each(function(){
      var mm_calorie = parseFloat($(this).find(".gram_calorie").val()) || 0;
      var mm_protein = parseFloat($(this).find(".gram_protein").val()) || 0;
      var mm_lipid = parseFloat($(this).find(".gram_lipid").val()) || 0;
      var mm_carbohydrate = parseFloat($(this).find(".gram_carbohydrate").val()) || 0;
      var mm_salt = parseFloat($(this).find(".gram_salt").val()) || 0;
      menu_calorie += mm_calorie;
      menu_protein += mm_protein;
      menu_lipid += mm_lipid;
      menu_carbohydrate += mm_carbohydrate;
      menu_salt += mm_salt;
    });
    
    $(".menu_calorie").val(menu_calorie.toFixed(1));
    $(".menu_protein").val(menu_protein.toFixed(1));
    $(".menu_lipid").val(menu_lipid.toFixed(1));
    $(".menu_carbohydrate").val(menu_carbohydrate.toFixed(1));
    $(".menu_salt").val(menu_salt.toFixed(1));
  }

}

document.addEventListener("DOMContentLoaded", onLoad);
document.addEventListener("turbo:load", onLoad);