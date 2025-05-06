function onLoad() {
  // 保存方法プリセット選択の処理
  $(document).on('click', '.preservation-preset', function(e) {
    e.preventDefault();
    const preservationText = $(this).data('value');
    $('#how_to_save_field').val(preservationText);
  });

  // 原材料表示自動生成ボタンのイベント処理
  $(document).on('click', '#generate-raw-materials-btn', function(e) {
    e.preventDefault();
    
    // ボタンの状態を更新
    const $btn = $(this);
    const originalBtnText = $btn.html();
    $btn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> 計算中...').prop('disabled', true);
    
    // 商品IDを取得
    const productId = $('#product-id').val();
    let url = '/products/generate_raw_materials_display';
    
    if (productId && productId.trim() !== '') {
      // 既存の商品の場合
      url = `/products/${productId}/generate_raw_materials_display`;
    }
    
    // フォームデータを取得
    let formData = null;
    try {
      formData = new FormData($('#product-form')[0]);
    } catch (error) {
      // フォームデータが取得できない場合は空のオブジェクトを送信
      formData = new FormData();
    }
    
    // CSRFトークンを取得
    const csrfToken = $('meta[name="csrf-token"]').attr('content');
    
    // Ajaxリクエストを送信
    $.ajax({
      url: url,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      headers: {
        'X-CSRF-Token': csrfToken
      },
      success: function(response) {
        // 原材料表示を更新
        $('#product_raw_materials_food_contents').val(response.food_contents);
        $('#product_raw_materials_additive_contents').val(response.additive_contents);
        
        // アレルギー情報を更新
        updateAllergensDisplay(response.allergens);
        
        // メニューがない場合、または結果が空の場合のメッセージ
        if (!response.food_contents && !response.additive_contents && (!response.allergens || response.allergens.length === 0)) {
          showMessage('原材料表示を計算できませんでした。商品にメニューが関連付けられていない可能性があります。まずメニューを追加してください。', 'warning');
        } else {
          // 成功メッセージを表示
          showMessage('原材料表示を計算しました。必要に応じて手動で調整してください。', 'success');
        }
        
        // ボタンの状態を元に戻す
        $btn.html(originalBtnText).prop('disabled', false);
      },
      error: function(xhr, status, error) {
        // エラーメッセージを表示
        showMessage('原材料表示の計算中にエラーが発生しました。', 'danger');
        
        // ボタンの状態を元に戻す
        $btn.html(originalBtnText).prop('disabled', false);
      }
    });
  });

  // アレルギー情報の表示を更新
  function updateAllergensDisplay(allergens) {
    const $allergensList = $('#product-allergens-list');
    $allergensList.empty();
    
    if (allergens && allergens.length > 0) {
      allergens.forEach(function(allergen) {
        const allergenName = allergen[1];
        
        $allergensList.append(
          `<span class="badge bg-warning text-dark me-2 mb-2">${allergenName}</span>`
        );
      });
      
      $('#allergens-container').removeClass('d-none');
    } else {
      $('#allergens-container').addClass('d-none');
    }
  }

  // 原価率計算の初期化
  function updateCostRatio() {
    var sellPrice = parseFloat($('.product_sell_price').val()) || 0;
    var costPrice = parseFloat($('.product_cost_price').val()) || 0;
    
    var costRatio = 0;
    if (sellPrice > 0) {
      costRatio = (costPrice / sellPrice) * 100;
    }
    
    // 原価率を表示（小数点第1位まで）
    $('.product_cost_ratio').val(costRatio.toFixed(1));
    
    // 原価率によって色を変更
    if (costRatio >= 30) {
      $('.product_cost_ratio').addClass('text-danger').removeClass('text-success');
    } else {
      $('.product_cost_ratio').addClass('text-success').removeClass('text-danger');
    }
  }
  
  // 売価が変更されたときに原価率を更新
  $('.product_sell_price').on('change keyup', function() {
    updateCostRatio();
  });
  
  // ページ読み込み時に初期化
  updateCostRatio();
  
  // メッセージを表示する関数
  function showMessage(message, type) {
    const alertDiv = $('<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' +
                      message +
                      '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="閉じる"></button>' +
                      '</div>');
    
    // メッセージを表示
    $('#message-container').html(alertDiv);
    
    // 数秒後に自動的に消える
    setTimeout(function() {
      alertDiv.alert('close');
    }, 5000);
  }
}

// ページ読み込み時に初期化
document.addEventListener("DOMContentLoaded", onLoad);
document.addEventListener("turbo:load", onLoad);