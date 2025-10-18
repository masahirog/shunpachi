function onLoad() {
  // Menu編集フォーム用のSortable初期化
  if ($('#menu_materials-add-point').length > 0) {
    // jQuery UIが利用可能かチェック
    if (typeof $.fn.sortable !== 'undefined') {
      initMenuMaterialsSortable();
    } else {
      // jQueryUIが読み込まれたら初期化を実行
      document.addEventListener('jquery-ui-loaded', initMenuMaterialsSortable);
    }

    // gram_quantity編集トグル機能
    initGramQuantityToggle();

    // ページロード時に原価・栄養計算を実行
    recalculateMenuValues();

    // 材料選択時の編集リンク更新
    initMaterialEditLink();
  }

  // メニュー選択時のイベント処理
  $("#product_menus-container").on('change', '.menu-select', function() {
    var menuId = $(this).val();
    var card = $(this).closest('.product-menu-item');
    var menuInfo = card.find('.menu-info');
    var materialsList = card.find('.materials-list');
    var allergensList = card.find('.allergens-list');
    
    // 編集リンクの更新 - 左側の編集ボタンコンテナを探す
    var editButtonsContainer = card.find('.edit-buttons-container');
    
    if (menuId && menuId !== '') {
      // メニュー編集リンクを更新または作成
      var editLink = editButtonsContainer.find('.edit-menu-link');
      
      if (editLink.length > 0) {
        // 既存のリンクを更新
        editLink.attr('href', '/menus/' + menuId + '/edit');
      } else {
        // 削除ボタンの前にリンクを新規作成
        editButtonsContainer.prepend(
          '<a href="/menus/' + menuId + '/edit" class="btn btn-outline-info btn-sm edit-menu-link" title="メニューを編集" target="_blank">' +
          '<i class="bi bi-pencil-square"></i> メニュー編集</a>'
        );
      }
    } else {
      // メニュー未選択の場合は編集リンクを削除
      editButtonsContainer.find('.edit-menu-link').remove();
    }
    
    // 未選択の場合は情報を非表示
    if (!menuId || menuId === '') {
      menuInfo.addClass('d-none');
      return;
    }
    menuInfo.removeClass('d-none');
    materialsList.html('<div class="text-center"><small>読み込み中...</small></div>');
    allergensList.html('<div class="text-center"><small>読み込み中...</small></div>');
    
    
    $.ajax({
      url: '/menus/' + menuId + '/details',
      type: 'GET',
      dataType: 'json',
      success: function(data) {
        
        // 基本情報を表示
        card.find('.menu-category').text(data.category_name);
        card.find('.menu-cost').text(data.cost_price + '円');
        
        // 栄養成分情報
        card.find('.menu-calorie').text(data.calorie + 'kcal');
        card.find('.menu-protein').text(data.protein + 'g');
        card.find('.menu-lipid').text(data.lipid + 'g');
        card.find('.menu-carbohydrate').text(data.carbohydrate + 'g');
        card.find('.menu-salt').text(data.salt + 'g');
        
        // 材料リストを生成
        if (data.menu_materials && data.menu_materials.length > 0) {
          var materialsHtml = '<div class="table-responsive"><table class="table table-sm table-hover mb-0">' +
                              '<thead class="table-light"><tr>' +
                              '<th class="small" style="width: 40%;">材料名</th>' +
                              '<th class="small" style="width: 25%;">数量</th>' +
                              '<th class="small" style="width: 35%;">下処理</th>' +
                              '</tr></thead><tbody>';

          data.menu_materials.forEach(function(material) {
            var materialName = material.name;
            if (material.material_id) {
              materialName = '<a href="/materials/' + material.material_id + '/edit" class="text-decoration-none" target="_blank">' + material.name + '</a>';
            }

            materialsHtml += '<tr>' +
                             '<td class="small">' + materialName + '</td>' +
                             '<td class="small">' + material.amount_used + ' ' + material.unit + '</td>' +
                             '<td class="small">' + (material.preparation || '—') + '</td>' +
                             '</tr>';
          });
          
          materialsHtml += '</tbody></table></div>';
          materialsList.html(materialsHtml);
        } else {
          materialsList.html('<div class="text-center"><small class="text-muted">登録されている材料はありません</small></div>');
        }

        // アレルギー情報を表示
        if (data.allergens && data.allergens.length > 0) {
          var allergensHtml = '<div class="mt-2">';
          data.allergens.forEach(function(allergen) {
            allergensHtml += '<span class="badge bg-warning text-dark me-1 mb-1">' + allergen[1] + '</span>';
          });
          allergensHtml += '</div>';
          allergensList.html(allergensHtml);
        } else {
          allergensList.html('<div class="text-center"><small class="text-muted">アレルギー情報はありません</small></div>');
        }
        
        // 商品の合計を更新
        updateProductTotals();
        // 商品全体のアレルギー情報を更新
        updateProductAllergens();
      },
      error: function(xhr, status, error) {
        menuInfo.addClass('d-none');
        allergensList.empty();
        alert("メニュー情報の取得に失敗しました");
      }
    });
  });
  
  // Cocoonのイベントハンドラ
  $("#product_menus-container").on('cocoon:after-insert', function(e, insertedItem) {
    // 追加された項目にフォーカス
    insertedItem.find('.menu-select').focus();
  });
  
  $("#product_menus-container").on('cocoon:after-remove', function() {
    // 項目が削除された後に合計を更新
    updateProductTotals();
    // 商品全体のアレルギー情報を更新
    updateProductAllergens();
  });
  
  // 既存のメニューを初期化（products/editページの場合のみ）
  if (window.location.pathname.includes('/products/') && window.location.pathname.includes('/edit')) {
    $('.menu-select').each(function() {
      if ($(this).val()) {
        $(this).trigger('change');
      }
    });
  }

  // 商品全体のアレルギー情報を更新
  function updateProductAllergens() {
    const $productAllergensList = $('#product-allergens-list');
    $productAllergensList.empty();
    
    // メニューごとのアレルギー情報を収集
    const allAllergens = new Set();
    $('.allergens-list .badge').each(function() {
      const allergenName = $(this).text();
      if (allergenName && !allergenName.includes('アレルギー情報はありません')) {
        allAllergens.add(allergenName);
      }
    });
    
    // アレルギー情報を表示
    if (allAllergens.size > 0) {
      Array.from(allAllergens).forEach(function(allergenName) {
        $productAllergensList.append(
          `<span class="badge bg-warning text-dark me-2 mb-2">${allergenName}</span>`
        );
      });
      $('#allergens-container').removeClass('d-none');
    } else {
      $('#allergens-container').addClass('d-none');
    }
  }

  // 商品の合計原価と栄養価を計算
  function updateProductTotals() {
    var totalCost = 0;
    var totalCalorie = 0;
    var totalProtein = 0;
    var totalLipid = 0;
    var totalCarbohydrate = 0;
    var totalSalt = 0;
    
    // 各メニューから値を取得して合計
    $('.menu-cost').each(function() {
      var text = $(this).text();
      if (text && text !== '--') {
        totalCost += parseFloat(text.replace('円', '')) || 0;
      }
    });
    
    $('.menu-calorie').each(function() {
      var text = $(this).text();
      if (text && text !== '--') {
        totalCalorie += parseFloat(text.replace('kcal', '')) || 0;
      }
    });
    
    $('.menu-protein').each(function() {
      var text = $(this).text();
      if (text && text !== '--') {
        totalProtein += parseFloat(text.replace('g', '')) || 0;
      }
    });
    
    $('.menu-lipid').each(function() {
      var text = $(this).text();
      if (text && text !== '--') {
        totalLipid += parseFloat(text.replace('g', '')) || 0;
      }
    });
    
    $('.menu-carbohydrate').each(function() {
      var text = $(this).text();
      if (text && text !== '--') {
        totalCarbohydrate += parseFloat(text.replace('g', '')) || 0;
      }
    });
    
    $('.menu-salt').each(function() {
      var text = $(this).text();
      if (text && text !== '--') {
        totalSalt += parseFloat(text.replace('g', '')) || 0;
      }
    });
    
    // 商品フォームに合計を設定
    $('.product_cost_price').val(totalCost.toFixed(2));
    $('.product_calorie').val(totalCalorie.toFixed(2));
    $('.product_protein').val(totalProtein.toFixed(2));
    $('.product_lipid').val(totalLipid.toFixed(2));
    $('.product_carbohydrate').val(totalCarbohydrate.toFixed(2));
    $('.product_salt').val(totalSalt.toFixed(2));
    
    // 原価率の更新
    updateCostRatio();
  }

  // 原価率の計算
  function updateCostRatio() {
    var sellPrice = parseFloat($('.product_sell_price').val()) || 0;
    var costPrice = parseFloat($('.product_cost_price').val()) || 0;
    
    var costRatio = 0;
    if (sellPrice > 0) {
      costRatio = (costPrice / sellPrice) * 100;
    }
    
    // 原価率を表示（小数点第1位まで）
    $('.product_cost_ratio').val(costRatio.toFixed(1));
    
    // 原価率によって色を変える（30%以上で警告色）
    if (costRatio >= 30) {
      $('.product_cost_ratio').addClass('text-danger').removeClass('text-success');
    } else {
      $('.product_cost_ratio').addClass('text-success').removeClass('text-danger');
    }
  }
  
  // 売価が変更されたときに原価率を更新
  $(".price").on('change keyup', '.product_sell_price', function() {
    updateCostRatio();
  });
}

// Menu材料のSortable初期化関数
function initMenuMaterialsSortable() {
  if ($.fn.sortable && $('#menu_materials-add-point').length > 0) {
    try {
      $("#menu_materials-add-point").sortable({
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
          updateMenuMaterialPositions();
        }
      });
    } catch (e) {
      console.error('Sortable initialization error:', e);
    }
  }
}

// 行の位置を更新する関数
function updateMenuMaterialPositions() {
  $('#menu_materials-add-point tr.nested-fields').each(function(index) {
    $(this).find('input[name*="[row_order]"]').val(index + 1);
  });
}

// メニュー編集ページで原価・栄養成分を再計算
function recalculateMenuValues() {
  // URLからメニューIDを取得
  const pathParts = window.location.pathname.split('/');
  const menuIdIndex = pathParts.indexOf('menus') + 1;
  const menuId = pathParts[menuIdIndex];

  // メニューIDが存在し、editページの場合のみ実行
  if (!menuId || pathParts[menuIdIndex + 1] !== 'edit') {
    return;
  }

  $.ajax({
    url: `/menus/${menuId}/calculate`,
    type: 'GET',
    dataType: 'json',
    success: function(data) {
      // メニュー全体の原価・栄養成分の値を更新
      $('.menu_cost_price').val(data.cost_price || 0);
      $('.menu_calorie').val(data.calorie || 0);
      $('.menu_protein').val(data.protein || 0);
      $('.menu_lipid').val(data.lipid || 0);
      $('.menu_carbohydrate').val(data.carbohydrate || 0);
      $('.menu_salt').val(data.salt || 0);

      // 各menu_materialの値を更新（インデックスベースで照合）
      if (data.menu_materials && data.menu_materials.length > 0) {
        const $rows = $('#menu_materials-add-point tr.nested-fields');

        data.menu_materials.forEach(function(mm, index) {
          // インデックスで対応する行を取得
          const $row = $rows.eq(index);

          if ($row.length > 0) {
            // cost_price を更新
            $row.find('.cost_price').val(mm.cost_price || 0);

            // 栄養成分を更新（gram_quantityは手動編集可能なので更新しない）
            $row.find('.gram_calorie').val(mm.calorie || 0);
            $row.find('.gram_protein').val(mm.protein || 0);
            $row.find('.gram_lipid').val(mm.lipid || 0);
            $row.find('.gram_carbohydrate').val(mm.carbohydrate || 0);
            $row.find('.gram_salt').val(mm.salt || 0);
          } else {
            console.warn(`インデックス${index}に対応する行が見つかりませんでした`);
          }
        });
      }
    },
    error: function(xhr, status, error) {
      console.error('メニュー計算の取得に失敗しました:', {
        status: status,
        error: error,
        response: xhr.responseText
      });
    }
  });
}

// gram_quantity編集トグル機能
function initGramQuantityToggle() {
  // 既存の編集ボタンにイベントを設定
  $(document).on('click', '.gram-quantity-edit-toggle', function(e) {
    e.preventDefault();
    const $button = $(this);
    const $row = $button.closest('tr.nested-fields');
    const $gramQuantityField = $row.find('.gram_quantity');

    // readonly属性をトグル
    if ($gramQuantityField.prop('readonly')) {
      $gramQuantityField.prop('readonly', false);
      $gramQuantityField.css('background-color', '#fff');
      $button.find('i').removeClass('bi-pencil').addClass('bi-check-circle');
      $button.find('i').css('color', '#28a745');
      // フィールドにフォーカスを設定して全選択
      $gramQuantityField.focus().select();
    } else {
      $gramQuantityField.prop('readonly', true);
      $gramQuantityField.css('background-color', '');
      $button.find('i').removeClass('bi-check-circle').addClass('bi-pencil');
      $button.find('i').css('color', 'green');
    }
  });

  // number_fieldのフォーカス/クリック時に全選択
  $(document).on('focus click', 'input[type="number"]', function() {
    // readonlyでない場合のみ全選択
    if (!$(this).prop('readonly')) {
      $(this).select();
    }
  });

  // 新しく追加された行にも対応
  $('#menu_materials-add-point').on('cocoon:after-insert', function(e, insertedItem) {
    // 新しく追加された行のgram_quantityフィールドもreadonlyに設定
    $(insertedItem).find('.gram_quantity').prop('readonly', true);
  });
}

// 材料選択時の編集リンク更新機能
function initMaterialEditLink() {
  // 材料選択変更時のイベント
  $(document).on('change', '.material_select2', function() {
    updateMaterialEditLink($(this));
  });

  // 新規追加された行にも対応
  $('#menu_materials-add-point').on('cocoon:after-insert', function(e, insertedItem) {
    // 新しく追加された行の編集リンクコンテナを初期化
    const $container = $(insertedItem).find('.d-flex.align-items-center');
    if ($container.length > 0) {
      // 既存の編集リンクがあれば削除
      $container.find('a').remove();
    }
  });

  // ページロード時に既存の行にも編集リンクを追加
  $('.material_select2').each(function() {
    updateMaterialEditLink($(this));
  });
}

// 材料の編集リンクを更新する関数
function updateMaterialEditLink($select) {
  const materialId = $select.val();
  const $container = $select.closest('.d-flex.align-items-center');

  // 既存の全ての編集リンク（<a>タグ）を削除
  $container.find('a').remove();

  // 材料が選択されている場合、編集リンクを追加
  if (materialId && materialId !== '') {
    const editLink = $('<a>', {
      href: `/materials/${materialId}/edit`,
      target: '_blank',
      class: 'btn btn-sm btn-outline-secondary ms-2 material-edit-link',
      title: '材料を編集',
      html: '<i class="bi bi-pencil-square"></i>'
    });

    $container.append(editLink);
  }
}

document.addEventListener("DOMContentLoaded", onLoad);
document.addEventListener("turbo:load", onLoad);