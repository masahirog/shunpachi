function onLoad() {
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
                              '<th class="small" style="width: 35%;">材料名</th>' +
                              '<th class="small" style="width: 20%;">数量</th>' +
                              '<th class="small" style="width: 35%;">下処理</th>' +
                              '<th class="small" style="width: 10%;">操作</th>' +
                              '</tr></thead><tbody>';
          
          data.menu_materials.forEach(function(material) {
            materialsHtml += '<tr>' +
                             '<td class="small">' + material.name + '</td>' +
                             '<td class="small">' + material.amount_used + ' ' + material.unit + '</td>' +
                             '<td class="small">' + (material.preparation || '—') + '</td>' +
                             '<td class="small">';
            
            // 材料編集リンクを追加
            if (material.material_id) {
              materialsHtml += '<a href="/materials/' + material.material_id + '/edit" class="btn btn-outline-info btn-sm" title="材料を編集" target="_blank">' +
                               '<i class="bi bi-pencil-square"></i></a>';
            }
            
            materialsHtml += '</td></tr>';
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
  
  // 既存のメニューを初期化
  $('.menu-select').each(function() {
    if ($(this).val()) {
      $(this).trigger('change');
    }
  });

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

document.addEventListener("DOMContentLoaded", onLoad);
document.addEventListener("turbo:load", onLoad);