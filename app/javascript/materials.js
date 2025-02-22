document.addEventListener("DOMContentLoaded", function() {

  $(".select2").select2({
    width: "100%",
    placeholder: "食材を検索",
    allowClear: true,
    language: {
      inputTooShort: function() {
        return "1文字以上入力してください";
      },
      noResults: function() {
        return "該当する食材が見つかりません";
      },
      searching: function() {
        return "検索中...";
      }
    },
    ajax: {
      url: "/food_ingredients/search",
      dataType: "json",
      delay: 250,
      data: function (params) {
        return {
          q: params.term
        };
      },
      processResults: function (data) {
        return {
          results: data.map(function (food_ingredient) {
            return { id: food_ingredient.id, text: food_ingredient.name };
          })
        };
      },
      cache: true
    },
    minimumInputLength: 1
  });

  $('#material_recipe_unit').on('change', function() {
    var unit = $(this).val();
    $(".label-recipe_unit_price").text("1" + unit + "の税抜価格");
  });
});
