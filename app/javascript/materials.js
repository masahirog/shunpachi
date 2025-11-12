function onLoad() {
  // 編集/新規作成ページのみで実行（重い処理をスキップ）
  const isFormPage = document.querySelector('#material-raw-materials') ||
                     document.querySelector('.material_select2') ||
                     document.querySelector('#menu_materials-add-point');

  if (isFormPage) {
    // 以下、フォームページのみで実行
    initSelect2();

    if (typeof $.fn.sortable !== 'undefined') {
      initSortable();
    } else {
      // jQueryUIが読み込まれたらinitSortableを実行
      document.addEventListener('jquery-ui-loaded', initSortable);
    }

    // 材料選択用のselect2を初期化
    material_select2();

    // Raw Material選択用のselect2を初期化
    initRawMaterialSelect2();

    // 材料追加ボタン押下時のイベント
    $('.add_material_fields').on('click', function(){
      setTimeout(function(){
        material_select2();
      }, 5);
    });
  }

  // Raw Material追加時のイベント
  $('#material-raw-materials').on('cocoon:after-insert', function(e, insertedItem) {
    // 新しく追加された行のselect2を初期化
    $(insertedItem).find('.raw-material-select2').select2({
      width: "100%",
      placeholder: "原材料を検索",
      allowClear: false,
      language: "ja"
    }).on('select2:select', function(e) {
      // 原材料が選択されたときのイベント処理
      const rawMaterialId = e.params.data.id;
      if (!rawMaterialId) return;

      const $row = $(this).closest('tr.nested-fields');
      const $badge = $row.find('td:nth-child(2) .category-badge');

      // カテゴリ情報を取得
      $.ajax({
        url: `/raw_materials/${rawMaterialId}.json`,
        type: 'GET',
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        success: function(data) {
          if (!data) return;

          if (data.category) {
            $badge.text(data.category_name).removeClass('d-none');
            $badge.attr('data-raw-material-id', rawMaterialId);
          } else {
            $badge.addClass('d-none');
          }
        },
        error: function() {
          $badge.addClass('d-none');
        }
      });
    }).on('select2:clear', function() {
      // 選択解除されたとき
      const $row = $(this).closest('tr.nested-fields');
      const $badge = $row.find('td:nth-child(2) .category-badge');

      // バッジを非表示
      $badge.addClass('d-none').attr('data-raw-material-id', '');
    });

    // percentage入力欄のイベントリスナーを追加
    $(insertedItem).find('.percentage-input').on('input change', updateTotalPercentage);

    // 位置番号を更新
    updateRowPositions();
  });

  // 材料削除後のイベント
  $(document).on('cocoon:after-remove', function(e, removed_item) {
    cal_cost_price();
    cal_food_ingredient();
    updateRowPositions();
    updateTotalPercentage();

    // sortableを再初期化
    setTimeout(function() {
      refreshSortable();
    }, 100);
  });

  // percentage入力欄の変更イベント
  $(document).on('input change', '.percentage-input', updateTotalPercentage);

  // percentage入力欄をクリック時に全選択
  $(document).on('focus click', '.percentage-input', function() {
    $(this).select();
  });


  // Sortable初期化関数
  function initSortable() {
    
    if ($.fn.sortable && $('#material-raw-materials').length > 0) {
      try {
        $("#material-raw-materials").sortable({
          items: "tr.nested-fields",
          handle: ".handle",
          axis: "y",
          cursor: "move",
          opacity: 0.7,
          placeholder: "ui-state-highlight",
          forcePlaceholderSize: true,
          start: function(e, ui) {
            // select2が開いていたら閉じる
            $('.select2-container--open').select2('close');
          },
          helper: function(e, tr) {
            var $originals = tr.children();
            var $helper = tr.clone();
            $helper.children().each(function(index) {
              // 幅を固定
              $(this).width($originals.eq(index).outerWidth());
            });
            return $helper;
          },
          update: function(e, ui) {
            updateRowPositions();
          }
        });
      } catch (e) {
      }
    } else {
    }
  }

  // Sortable再初期化関数
  function refreshSortable() {
    if ($("#material-raw-materials").data('ui-sortable')) {
      $("#material-raw-materials").sortable('refresh');
    } else {
      initSortable();
    }
  }

  // 行の位置を更新する関数
  function updateRowPositions() {
    $('#material-raw-materials tr.nested-fields').each(function(index) {
      $(this).find('input[name*="position"]').val(index + 1);
    });
  }

  // 材料選択用のselect2初期化関数
  function material_select2(){
    // 初期化されているselect2をチェック
    $(".material_select2").each(function() {
      if ($(this).hasClass('select2-hidden-accessible')) {
        $(this).select2('destroy');
      }
    });

    $(".material_select2").select2({
      width: "100%",
      placeholder: "食材を検索",
      allowClear: false,
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
            var foodIngredientLink = `<span>食成：</span><a href="/food_ingredients/${data.food_ingredient.id}" target="_blank" class="food-ingredient-link">${data.food_ingredient.name}</a>`;
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

  // percentage合計を更新する関数
  function updateTotalPercentage() {
    let total = 0;
    $('#material-raw-materials tr.nested-fields:visible').each(function() {
      const percentage = parseInt($(this).find('.percentage-input').val()) || 0;
      total += percentage;
    });

    $('#total-percentage-value').text(total);

    // 100%を超えた場合は警告表示
    if (total > 100) {
      $('#total-percentage-value').removeClass('text-dark').addClass('text-danger');
    } else {
      $('#total-percentage-value').removeClass('text-danger').addClass('text-dark');
    }
  }

  // 初期化時に行の位置を設定
  updateRowPositions();
  // 初期化時にpercentage合計を表示
  updateTotalPercentage();
}


// Select2を初期化する関数
function initSelect2() {
  // 基本的な初期化
  $('.select2').select2({
    placeholder: '選択してください',
    allowClear: false,
    width: '100%',
    language: {
      noResults: function() {
        return "一致する食品成分がありません";
      }
    }
  });

  // FoodIngredient用の特別な設定
  $('select[name="material[food_ingredient_id]"]').select2({
    placeholder: '食品成分を検索...',
    allowClear: false,
    width: '100%',
    minimumInputLength: 1,
    language: {
      inputTooShort: function() {
        return "検索するには文字を入力してください";
      },
      noResults: function() {
        return "一致する食品成分がありません";
      },
      searching: function() {
        return "検索中...";
      }
    }
  });
}



// Raw Materialのselect2初期化関数 - 既存の初期化関数を更新
function initRawMaterialSelect2() {
  
  // CSRFトークン取得
  const csrfToken = $('meta[name="csrf-token"]').attr('content');
  
  // 初期化されているselect2をチェックして、初期化済みのものだけdestroyする
  $('.raw-material-select2').each(function() {
    // data属性やクラスでselect2が適用済みかチェック
    if ($(this).hasClass('select2-hidden-accessible')) {
      $(this).select2('destroy');
    }
  });
  
  // select2を適用
  $('.raw-material-select2').select2({
    width: "100%",
    placeholder: "原材料を検索",
    allowClear: false,
    language: "ja"
  }).on('select2:select', function(e) {
    // 原材料が選択されたとき
    const rawMaterialId = e.params.data.id;
    const $row = $(this).closest('tr.nested-fields');
    const $badge = $row.find('td:nth-child(2) .category-badge');
    
    // カテゴリ情報を取得
    $.ajax({
      url: `/raw_materials/${rawMaterialId}.json`,
      type: 'GET',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      success: function(data) {
        if (data.category) {
          $badge.text(data.category_name).removeClass('d-none');
          $badge.attr('data-raw-material-id', rawMaterialId);
        } else {
          $badge.addClass('d-none');
        }
      },
      error: function() {
        $badge.addClass('d-none');
      }
    });
  }).on('select2:clear', function() {
    // 選択解除されたとき
    const $row = $(this).closest('tr.nested-fields');
    const $badge = $row.find('td:nth-child(2) .category-badge');
    
    // バッジを非表示
    $badge.addClass('d-none').attr('data-raw-material-id', '');
  });
}

// 原材料作成のための関数
function initRawMaterialCreation() {
  // 保存ボタンのクリックイベント
  $('#saveRawMaterial').on('click', function() {
    const name = $('#new_raw_material_name').val();
    const category = $('#new_raw_material_category').val();
    const description = $('#new_raw_material_description').val();
    
    // 入力チェック
    if (!name) {
      $('#rawMaterialFormError').removeClass('d-none').text('原材料名は必須です');
      return;
    }

    if (!category) {
      $('#rawMaterialFormError').removeClass('d-none').text('カテゴリーは必須です');
      return;
    }
    
    // エラーメッセージをクリア
    $('#rawMaterialFormError').addClass('d-none');
    
    // 保存中の表示
    const originalBtnText = $(this).text();
    $(this).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> 保存中...').prop('disabled', true);
    
    // CSRFトークン取得
    const csrfToken = $('meta[name="csrf-token"]').attr('content');
    
    // 非同期で原材料を作成
    $.ajax({
      url: '/raw_materials',
      type: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      data: {
        raw_material: {
          name: name,
          category: category,
          description: description
        },
        format: 'json'
      },
      success: function(data) {
        // 作成した原材料の表示名を使用（サーバーから取得）
        const displayName = data.display_name || data.name;

        // 全てのraw-material-select2を更新
        $('.raw-material-select2').each(function() {
          const $select = $(this);

          // select2が初期化されているかチェック
          if ($select.hasClass('select2-hidden-accessible')) {
            // select2が初期化済みの場合
            // 新しいオプションを追加
            const newOption = new Option(displayName, data.id, false, false);
            $select.append(newOption);

            // select2のデータを更新
            $select.trigger('change.select2');
          } else {
            // select2が未初期化の場合（動的に追加されたばかりの要素）
            // 通常のoptionとして追加
            const newOption = $('<option></option>')
              .attr('value', data.id)
              .text(displayName);
            $select.append(newOption);
          }
        });

        // モーダルを開いたセレクトボックスがあれば、そこに新しい値を設定
        const $currentSelect = $('.currently-adding-raw-material');
        if ($currentSelect.length) {
          // select2が初期化されているかチェック
          if ($currentSelect.hasClass('select2-hidden-accessible')) {
            $currentSelect.val(data.id).trigger('change');
          } else {
            $currentSelect.val(data.id);
          }
          $currentSelect.removeClass('currently-adding-raw-material');
        }
        
        // モーダルをリセットして閉じる
        $('#new_raw_material_name').val('');
        $('#new_raw_material_category').val('');
        $('#new_raw_material_description').val('');
        $('#newRawMaterialModal').modal('hide');
        
        // 保存ボタンを元に戻す
        $('#saveRawMaterial').html(originalBtnText).prop('disabled', false);
        
        // 成功メッセージ
        toastr.success('原材料を作成しました');
      },
      error: function(xhr) {
        let errorMessage = '原材料の作成に失敗しました';
        if (xhr.responseJSON && xhr.responseJSON.errors) {
          errorMessage = xhr.responseJSON.errors.join('<br>');
        }
        $('#rawMaterialFormError').removeClass('d-none').html(errorMessage);
        
        // 保存ボタンを元に戻す
        $('#saveRawMaterial').html(originalBtnText).prop('disabled', false);
      }
    });
  });
  
  // 新規作成ボタンのクリックイベント
  $(document).on('click', '.new-raw-material-btn', function() {
    // クリックされたボタンに関連するセレクトボックスをマーク
    $(this).closest('.d-flex').find('.raw-material-select2').addClass('currently-adding-raw-material');
  });
  
  // モーダルが閉じられたとき
  $('#newRawMaterialModal').on('hidden.bs.modal', function() {
    // エラーメッセージをクリア
    $('#rawMaterialFormError').addClass('d-none');
    // 現在追加中のマークをクリア
    $('.currently-adding-raw-material').removeClass('currently-adding-raw-material');
  });
}

// Turboの前にselect2破棄
$(document).on("turbo:before-cache", function() {
  // Select2が初期化されているものだけdestroyする
  $('.material_select2.select2-hidden-accessible').select2('destroy');
  $('.raw-material-select2.select2-hidden-accessible').select2('destroy');
  
  // Sortableも破棄
  if ($("#material-raw-materials").data('ui-sortable')) {
    $("#material-raw-materials").sortable('destroy');
  }
});


// 食品成分作成のための関数
function initFoodIngredientCreation() {
  // 保存ボタンのクリックイベント
  $('#saveFoodIngredient').on('click', function() {
    const name = $('#new_food_ingredient_name').val();
    const calorie = $('#new_food_ingredient_calorie').val();
    const protein = $('#new_food_ingredient_protein').val();
    const lipid = $('#new_food_ingredient_lipid').val();
    const carbohydrate = $('#new_food_ingredient_carbohydrate').val();
    const salt = $('#new_food_ingredient_salt').val();
    const memo = $('#new_food_ingredient_memo').val();

    // 入力チェック
    if (!name) {
      $('#foodIngredientFormError').removeClass('d-none').text('食品成分名は必須です');
      return;
    }

    // 数値フィールドの必須チェック
    if (!calorie || !protein || !lipid || !carbohydrate || !salt) {
      $('#foodIngredientFormError').removeClass('d-none').text('カロリー、タンパク質、脂質、炭水化物、食塩相当量は必須です');
      return;
    }

    // エラーメッセージをクリア
    $('#foodIngredientFormError').addClass('d-none');

    // 保存中の表示
    const originalBtnText = $(this).text();
    $(this).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> 保存中...').prop('disabled', true);

    // CSRFトークン取得
    const csrfToken = $('meta[name="csrf-token"]').attr('content');

    // 非同期で食品成分を作成
    $.ajax({
      url: '/food_ingredients',
      type: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      data: {
        food_ingredient: {
          name: name,
          calorie: calorie,
          protein: protein,
          lipid: lipid,
          carbohydrate: carbohydrate,
          salt: salt,
          memo: memo || null
        },
        format: 'json'
      },
      success: function(data) {
        // 作成した食品成分の表示名を使用（サーバーから取得）
        const displayName = data.display_name || data.name;

        // 全てのfood-ingredient-select2を更新
        $('.food-ingredient-select2').each(function() {
          const $select = $(this);

          // select2が初期化されているかチェック
          if ($select.hasClass('select2-hidden-accessible')) {
            // select2が初期化済みの場合
            // 新しいオプションを追加
            const newOption = new Option(displayName, data.id, false, false);
            $select.append(newOption);

            // select2のデータを更新
            $select.trigger('change.select2');
          } else {
            // select2が未初期化の場合
            // 通常のoptionとして追加
            const newOption = $('<option></option>')
              .attr('value', data.id)
              .text(displayName);
            $select.append(newOption);
          }
        });

        // モーダルを開いたセレクトボックスがあれば、そこに新しい値を設定
        const $currentSelect = $('.currently-adding-food-ingredient');
        if ($currentSelect.length) {
          // select2が初期化されているかチェック
          if ($currentSelect.hasClass('select2-hidden-accessible')) {
            $currentSelect.val(data.id).trigger('change');
          } else {
            $currentSelect.val(data.id);
          }
          $currentSelect.removeClass('currently-adding-food-ingredient');
        }

        // モーダルをリセットして閉じる
        $('#new_food_ingredient_name').val('');
        $('#new_food_ingredient_calorie').val('');
        $('#new_food_ingredient_protein').val('');
        $('#new_food_ingredient_lipid').val('');
        $('#new_food_ingredient_carbohydrate').val('');
        $('#new_food_ingredient_salt').val('');
        $('#new_food_ingredient_memo').val('');
        $('#newFoodIngredientModal').modal('hide');

        // 保存ボタンを元に戻す
        $('#saveFoodIngredient').html(originalBtnText).prop('disabled', false);

        // 成功メッセージ
        toastr.success('食品成分を作成しました');
      },
      error: function(xhr) {
        let errorMessage = '食品成分の作成に失敗しました';
        if (xhr.responseJSON && xhr.responseJSON.errors) {
          errorMessage = xhr.responseJSON.errors.join('<br>');
        }
        $('#foodIngredientFormError').removeClass('d-none').html(errorMessage);

        // 保存ボタンを元に戻す
        $('#saveFoodIngredient').html(originalBtnText).prop('disabled', false);
      }
    });
  });

  // 新規作成ボタンのクリックイベント
  $(document).on('click', '.new-food-ingredient-btn', function() {
    // クリックされたボタンに関連するセレクトボックスをマーク
    $(this).closest('.d-flex').find('.food-ingredient-select2').addClass('currently-adding-food-ingredient');
  });

  // モーダルが閉じられたとき
  $('#newFoodIngredientModal').on('hidden.bs.modal', function() {
    // エラーメッセージをクリア
    $('#foodIngredientFormError').addClass('d-none');
    // 現在追加中のマークをクリア
    $('.currently-adding-food-ingredient').removeClass('currently-adding-food-ingredient');
  });
}

// ページロード時の初期化
document.addEventListener("DOMContentLoaded", function() {
  onLoad();
  initRawMaterialCreation();
  initFoodIngredientCreation();
});
document.addEventListener("turbo:load", function() {
  onLoad();
  initRawMaterialCreation();
  initFoodIngredientCreation();
});
