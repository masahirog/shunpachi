function onLoad() {

  // メニュー選択時のイベント処理
  $(document).on('change', '.menu-select', function() {
    var menuId = $(this).val();
    var card = $(this).closest('.product-menu-item');
    var menuInfo = card.find('.menu-info');
    var materialsList = card.find('.materials-list');
    
    // 未選択の場合は情報を非表示
    if (!menuId || menuId === '') {
      menuInfo.addClass('d-none');
      return;
    }
    
    // 選択されたメニューのデータをリクエスト
    console.log("メニューID: " + menuId + "のデータを取得します");
    
    // 読み込み中の表示
    menuInfo.removeClass('d-none');
    materialsList.html('<div class="text-center"><small>読み込み中...</small></div>');
    
    $.ajax({
      url: '/menus/' + menuId + '/details',
      type: 'GET',
      dataType: 'json',
      success: function(data) {
        console.log("データ取得成功:", data);
        
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
            materialsHtml += '<tr>' +
                             '<td class="small">' + material.name + '</td>' +
                             '<td class="small">' + material.amount_used + ' ' + material.unit + '</td>' +
                             '<td class="small">' + (material.preparation || '—') + '</td>' +
                             '</tr>';
          });
          
          materialsHtml += '</tbody></table></div>';
          materialsList.html(materialsHtml);
        } else {
          materialsList.html('<div class="text-center"><small class="text-muted">登録されている材料はありません</small></div>');
        }
        
        // 商品の合計を更新
        updateProductTotals();
      },
      error: function(xhr, status, error) {
        console.error("エラー発生:", status, error);
        console.log(xhr.responseText);
        menuInfo.addClass('d-none');
        alert("メニュー情報の取得に失敗しました");
      }
    });
  });
  
  // Cocoonのイベントハンドラ
  $(document).on('cocoon:after-insert', function(e, insertedItem) {
    console.log("新しいメニュー項目が追加されました");
    // 追加された項目にフォーカス
    insertedItem.find('.menu-select').focus();
  });
  
  $(document).on('cocoon:before-remove', function(e, item) {
    // 削除前の処理（確認など必要であれば）
  });
  
  $(document).on('cocoon:after-remove', function() {
    // 項目が削除された後に合計を更新
    updateProductTotals();
  });
  
  // 既存のメニューを初期化
  $('.menu-select').each(function() {
    if ($(this).val()) {
      $(this).trigger('change');
    }
  });

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
    
    console.log("商品合計を更新: 原価=" + totalCost.toFixed(2));
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
  $(document).on('change keyup', '.product_sell_price', function() {
    updateCostRatio();
  });

}


document.addEventListener("DOMContentLoaded", onLoad);
document.addEventListener("turbo:load", onLoad);