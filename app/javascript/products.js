function onLoad() {
  // メニュー選択にselect2を適用
  initProductMenuSelect2();

  // 保存方法プリセット選択の処理
  $(document).on('click', '.preservation-preset', function(e) {
    e.preventDefault();
    const preservationText = $(this).data('value');
    $('#how_to_save_field').val(preservationText);
  });

  // 原材料表示自動生成ボタンのイベント処理
  $(document).on('click', '#generate-raw-materials-btn', function(e) {
    e.preventDefault(); // フォーム送信を防止
    
    // ボタンの状態を更新
    const $btn = $(this);
    const originalBtnText = $btn.html();
    $btn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> 計算中...').prop('disabled', true);
    
    // 商品IDを取得 (data-product-id属性から)
    const productId = $('#product-id').val();
    
    console.log('原材料表示自動生成 - 開始:', { productId: productId });
    
    // 現在のフォームデータを取得
    const formData = new FormData();
    
    // 基本的な商品データをフォームから収集
    formData.append('product[name]', $('#product_name').val());
    formData.append('product[category]', $('#product_category').val());
    
    // プロダクトメニューデータを収集
    $('.menu-select').each(function(index) {
      const menuId = $(this).val();
      if (menuId) {
        formData.append(`product[product_menus_attributes][${index}][menu_id]`, menuId);
        
        // 既存のメニューIDがある場合は追加
        const existingId = $(this).closest('.nested-fields').find('input[name*="[id]"]').val();
        if (existingId) {
          formData.append(`product[product_menus_attributes][${index}][id]`, existingId);
        }
        
        formData.append(`product[product_menus_attributes][${index}][_destroy]`, 'false');
      }
    });
    
    // CSRF トークン
    const csrfToken = $('meta[name="csrf-token"]').attr('content');
    
    // URLを決定（新規作成か編集かで分岐）
    let url = '/products/generate_raw_materials';
    if (productId && productId !== '') {
      url = `/products/${productId}/generate_raw_materials`;
    }
    
    console.log('原材料表示自動生成 - リクエスト送信:', { url: url, method: 'POST' });
    
    // Ajaxリクエスト
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
        console.log('原材料表示自動生成 - 成功:', response);
        
        // 原材料表示を更新
        $('#product_raw_materials_food_contents').val(response.food_contents || '');
        $('#product_raw_materials_additive_contents').val(response.additive_contents || '');
        
        // アレルギー情報を更新
        updateAllergensDisplay(response.allergens || []);
        
        // 成功メッセージを表示
        showMessage('原材料表示を計算しました', 'success');
        
        // ボタンを元に戻す
        $btn.html(originalBtnText).prop('disabled', false);
      },
      error: function(xhr, status, error) {
        console.error('原材料表示自動生成 - エラー:', {
          status: status,
          error: error,
          response: xhr.responseText
        });
        
        // エラーメッセージを表示
        showMessage('エラーが発生しました: ' + error, 'danger');
        
        // ボタンを元に戻す
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
  
  // メニュー選択にselect2を適用する関数
  function initProductMenuSelect2() {
    // 既存のselect2を破棄（二重初期化防止）
    $('.menu-select').each(function() {
      if ($(this).hasClass('select2-hidden-accessible')) {
        $(this).select2('destroy');
      }
    });

    // select2を適用
    $('.menu-select').select2({
      placeholder: 'メニューを選択',
      allowClear: true,
      width: '100%'
    });

    // select2の選択イベントを設定
    $('.menu-select').on('select2:select', function(e) {
      // 既存のchangeイベントを手動でトリガー
      $(this).trigger('change');
    });
  }

  // 商品メニュー追加時のイベント
  $("#product_menus-container").on('cocoon:after-insert', function(e, insertedItem) {
    // 新しく追加されたメニュー選択に対してselect2を適用
    const newSelect = insertedItem.find('.menu-select');
    
    if (newSelect.length) {
      newSelect.select2({
        placeholder: 'メニューを選択',
        allowClear: true,
        width: '100%'
      });
      
      // フォーカスを設定
      setTimeout(function() {
        newSelect.select2('focus');
      }, 100);
    }
  });

  // フォーム送信時のバリデーション
  $('#product-form').on('submit', function(e) {
    // 必須項目のチェック
    const requiredFields = $('.form-control.required');
    let hasErrors = false;
    
    requiredFields.each(function() {
      if (!$(this).val()) {
        $(this).addClass('is-invalid');
        hasErrors = true;
      } else {
        $(this).removeClass('is-invalid');
      }
    });
    
    if (hasErrors) {
      e.preventDefault();
      showMessage('必須項目が入力されていません。', 'danger');
      
      // 最初のエラーフィールドにフォーカス
      $('.form-control.is-invalid').first().focus();
    }
  });
  
  // Turbo処理前のselect2のクリーンアップ
  $(document).on('turbo:before-cache', function() {
    $('.menu-select.select2-hidden-accessible').select2('destroy');
  });
}

// ページ読み込み時に初期化
document.addEventListener("DOMContentLoaded", onLoad);
document.addEventListener("turbo:load", onLoad);