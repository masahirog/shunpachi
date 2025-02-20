document.addEventListener("DOMContentLoaded", function() {
  console.log("materials");
  if (typeof $ === "undefined") {
    console.error("jQuery が読み込まれていません！");
    return;
  }

  $('#material_recipe_unit').on('change', function() {
    var unit = $(this).val();
    $(".label-recipe_unit_price").text("1" + unit + "の税抜価格");
  });
});