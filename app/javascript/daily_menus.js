function onLoad() {
  // 編集ページのみで実行（indexページでは不要）
  if (!document.querySelector('.js-daily-menu-products-container')) {
    return;
  }

  // 商品追加ボタンのクリックイベント
  $("#addProductModal").on('click', '.js-add-product-btn', function() {

    const row = $(this).closest('tr');
    const productId = row.data('id');
    const productName = row.data('name');
    const category = row.data('category');
    const sellPrice = row.data('sell-price');
    const costPrice = row.data('cost-price');
    
    const isDuplicate = checkProductDuplicate(productId);
    if (isDuplicate) {
      toastr.error(`${productName}はすでに献立に追加されています`);
      return;
    }
    
    // 商品を献立に追加
    addProductToDailyMenu(productId, productName, category, sellPrice, costPrice);
  });

  // 商品の重複チェック関数
  function checkProductDuplicate(productId) {
    let isDuplicate = false;
    $('.js-daily-menu-product-row').each(function() {
      const existingProductId = $(this).data('product-id');
      if (existingProductId == productId) {
        isDuplicate = true;
        return false; // eachループを抜ける
      }
    });
    return isDuplicate;
  }
  
  // 商品検索フィルター
  $('.js-product-search').on('keyup', function() {
    const searchText = $(this).val().toLowerCase();
    $('.js-product-row').each(function() {
      const productName = $(this).data('name').toLowerCase();
      if (productName.includes(searchText)) {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  });
  
  function addProductToDailyMenu(productId, productName, category, sellPrice, costPrice) {
    // 新しいIDを生成
    const newId = new Date().getTime();
    
    // 店舗のセルを生成 - ここを修正
    let storeCells = '';
    let storeIndex = 0; // 追加：配列用のインデックス
    
    $('.store-header').each(function() {
      const storeId = $(this).data('store-id');
      const storeName = $(this).text();
      
      storeCells += `
        <td class="text-center js-store-quantity-cell" data-store-id="${storeId}">
          <input type="number" id="quantity_new_${newId}_store_${storeId}" class="form-control form-control-sm js-store-quantity text-center" min="0" value="0" data-daily-menu-product-id="temp_${newId}" data-store-id="${storeId}" autocomplete="off">
          <input type="hidden" name="daily_menu[daily_menu_products_attributes][${newId}][store_daily_menu_products_attributes][${storeIndex}][store_id]" value="${storeId}">
          <input type="hidden" name="daily_menu[daily_menu_products_attributes][${newId}][store_daily_menu_products_attributes][${storeIndex}][number]" value="0" class="js-store-quantity-hidden">
          <input type="hidden" name="daily_menu[daily_menu_products_attributes][${newId}][store_daily_menu_products_attributes][${storeIndex}][total_price]" value="0" class="js-store-total-price-hidden">
        </td>
      `;
      
      storeIndex++; // インデックスをインクリメント
    });
    
    // 商品行のHTMLを生成
    const newRow = `
      <tr class="nested-fields js-daily-menu-product-row" data-product-id="${productId}" data-sell-price="${sellPrice}" data-cost-price="${costPrice}" data-daily-menu-product-id="temp_${newId}">
        <td class="handle">
          <i class="bi bi-grip-vertical text-muted"></i>
        </td>
        <td>
          <input type="hidden" name="daily_menu[daily_menu_products_attributes][${newId}][product_id]" value="${productId}">
          <input type="hidden" name="daily_menu[daily_menu_products_attributes][${newId}][sell_price]" value="${sellPrice}">
          <input type="hidden" name="daily_menu[daily_menu_products_attributes][${newId}][total_cost_price]" value="${costPrice}">
          ${productName}
        </td>
        <td class="text-center">
          <span class="badge rounded-pill bg-info text-dark">${category}</span>
        </td>
        <td class="text-end js-product-sell-price">
          ${formatCurrency(sellPrice)}
        </td>
        <td class="text-end js-product-total-cost-price">
          ${formatCurrency(costPrice)}
        </td>
        ${storeCells}
        <td class="text-center">
          <input class="form-control form-control-sm js-manufacturing-number text-center" type="number" value="0" min="0" name="daily_menu[daily_menu_products_attributes][${newId}][manufacturing_number]" readonly>
        </td>
        <td class="text-center">
          <a class="btn btn-sm btn-outline-danger js-remove-product-btn" href="#">
            <i class="bi bi-trash"></i>
          </a>
        </td>
      </tr>
    `;
    
    // 商品テーブルに行を追加
    $('.js-daily-menu-products-container').append(newRow);
    
    // 合計を更新
    updateTotals();
    
    // フィードバック
    toastr.success(`${productName}を追加しました`);
  }
  
  // 店舗数量の入力イベント
  $(".js-daily-menu-products-container").on('change keyup', '.js-store-quantity', function() {
    const row = $(this).closest('.js-daily-menu-product-row');
    const sellPrice = parseFloat(row.data('sell-price')) || 0;
    const storeId = $(this).data('store-id');
    const quantity = parseInt($(this).val()) || 0;
    
    // hidden フィールドを更新
    $(this).siblings('.js-store-quantity-hidden').val(quantity);
    $(this).siblings('.js-store-total-price-hidden').val(quantity * sellPrice);
    
    // 製造数を更新（各店舗の合計）
    updateManufacturingNumber(row);
    
    // 合計を更新
    updateTotals();
    
    // 上部の店舗合計を更新
    updateStoreSummary();
  });

  // 店舗合計を更新する関数
  function updateStoreSummary() {
    $('.store-summary-row').each(function() {
      const storeId = $(this).data('store-id');
      let totalQuantity = 0;
      let totalPrice = 0;
      
      $('.js-store-quantity').each(function() {
        if ($(this).data('store-id') == storeId) {
          const row = $(this).closest('.js-daily-menu-product-row');
          const sellPrice = parseFloat(row.data('sell-price')) || 0;
          const quantity = parseInt($(this).val()) || 0;
          
          totalQuantity += quantity;
          totalPrice += (sellPrice * quantity);
        }
      });
      
      // 総数を更新
      $(this).find('.store-total-count').text(totalQuantity);
      
      // 金額を更新
      $(this).find('.store-total-price').text(formatCurrency(totalPrice));
      
      // 状態を更新
      const badge = $(this).find('.badge');
      if (totalQuantity > 0) {
        badge.removeClass('bg-secondary').addClass('bg-success').text('配分済');
      } else {
        badge.removeClass('bg-success').addClass('bg-secondary').text('未設定');
      }
    });
  }
  
  // 製造数更新関数（各店舗の合計）
  function updateManufacturingNumber(row) {
    let total = 0;
    row.find('.js-store-quantity').each(function() {
      total += parseInt($(this).val()) || 0;
    });
    
    row.find('.js-manufacturing-number').val(total);
  }
  
  // 金額フォーマット関数
  function formatCurrency(amount) {
    return '¥' + Number(amount).toLocaleString();
  }
  
  // 商品削除ボタンのクリックイベント
  $(document).on('click', '.js-remove-product-btn', function(e) {
    e.preventDefault();
    const row = $(this).closest('.js-daily-menu-product-row');
    
    if (confirm('この商品を削除してもよろしいですか？')) {
      row.remove();
      updateTotals();
      toastr.info('商品を削除しました');
    }
  });
  
  function updateTotals() {
    let totalSelling = 0;
    let totalCost = 0;
    let totalManufacturing = 0;
    
    // 店舗ごとの合計を初期化
    $('.js-store-total').each(function() {
      $(this).text('0');
    });
    
    $('.js-daily-menu-product-row').each(function() {
      const row = $(this);
      const sellPrice = parseFloat(row.data('sell-price')) || 0;
      const costPrice = parseFloat(row.data('cost-price')) || 0;
      const manufacturingNumber = parseInt(row.find('.js-manufacturing-number').val()) || 0;
      
      // 商品ごとの金額計算
      totalSelling += sellPrice * manufacturingNumber;
      totalCost += costPrice * manufacturingNumber;
      totalManufacturing += manufacturingNumber;
      
      // 店舗ごとの合計を計算
      row.find('.js-store-quantity').each(function() {
        const storeId = $(this).data('store-id');
        const quantity = parseInt($(this).val()) || 0;
        const storeTotal = parseInt($('.js-store-total[data-store-id="' + storeId + '"]').text()) || 0;
        $('.js-store-total[data-store-id="' + storeId + '"]').text(storeTotal + quantity);
      });
    });
    
    // 合計を表示
    $('.daily-menu-products-total-selling-price').text(formatCurrency(totalSelling));
    $('.daily-menu-products-total-cost-price').text(formatCurrency(totalCost));
    $('.daily-menu-products-total-manufacturing-number').text(totalManufacturing);
    
    // 基本情報の金額も更新
    $('.daily-menu-total-selling-price').val(totalSelling);
    $('.daily-menu-total-cost-price').val(totalCost);
    
    // 左上の製造数フィールドを更新（ここを追加）
    $('.daily-menu-total-manufacturing').val(totalManufacturing);
    
    // 原価率を計算
    let costRatio = 0;
    if (totalSelling > 0) {
      costRatio = (totalCost / totalSelling) * 100;
    }
    $('.daily-menu-cost-ratio').val(costRatio.toFixed(1));
    
    // 原価率によって色を変更
    if (costRatio <= 30) {
      $('.daily-menu-cost-ratio').removeClass('text-danger text-warning').addClass('text-success');
    } else if (costRatio <= 40) {
      $('.daily-menu-cost-ratio').removeClass('text-danger text-success').addClass('text-warning');
    } else {
      $('.daily-menu-cost-ratio').removeClass('text-success text-warning').addClass('text-danger');
    }
  

    // 店舗配分の合計を更新（右上のカード部分）
    $('.store-summary-row').each(function() {
      const storeId = $(this).data('store-id');
      let storeCount = 0;
      let storeTotalPrice = 0;
      
      // 各商品の店舗数量を集計
      $('.js-daily-menu-product-row').each(function() {
        const sellPrice = parseFloat($(this).data('sell-price')) || 0;
        const quantity = parseInt($(this).find(`.js-store-quantity[data-store-id="${storeId}"]`).val()) || 0;
        storeCount += quantity;
        storeTotalPrice += sellPrice * quantity;
      });
      
      // 右上のカードに反映
      $(this).find('.store-total-count').text(storeCount);
      $(this).find('.store-total-price').text(formatCurrency(storeTotalPrice));
      
      // バッジの更新
      const badge = $(this).find('.badge');
      if (storeCount > 0) {
        badge.removeClass('bg-secondary').addClass('bg-success').text('配分済');
      } else {
        badge.removeClass('bg-success').addClass('bg-secondary').text('未設定');
      }
    });
  }
  
  // 既存行の製造数を更新（ページ読み込み時）
  $('.js-daily-menu-product-row').each(function() {
    updateManufacturingNumber($(this));
  });
  
  // 初期合計計算
  updateTotals();
  
  // Toastrライブラリが読み込まれていない場合の簡易実装
  if (typeof toastr === 'undefined') {
    window.toastr = {
      success: function(message) {
        alert(message);
      },
      error: function(message) {
        alert('エラー: ' + message);
      },
      info: function(message) {
        alert('情報: ' + message);
      }
    };
  }


  // モーダルが開かれたときの処理
  $('#addProductModal').on('show.bs.modal', function() {
    // 検索フィールドをクリア
    $('.js-product-search').val('');
    
    // 既に追加されている商品IDのリストを作成
    const addedProductIds = [];
    $('.js-daily-menu-product-row').each(function() {
      addedProductIds.push($(this).data('product-id'));
    });
    
    // 商品リストを更新
    $('.js-product-row').each(function() {
      const productId = $(this).data('id');
      
      // 既に追加されている商品はグレーアウト
      if (addedProductIds.includes(productId)) {
        $(this).addClass('text-muted bg-light');
        $(this).find('.js-add-product-btn').prop('disabled', true)
               .removeClass('btn-primary')
               .addClass('btn-secondary')
               .html('<i class="bi bi-check"></i> 追加済');
      } else {
        $(this).removeClass('text-muted bg-light');
        $(this).find('.js-add-product-btn').prop('disabled', false)
               .removeClass('btn-secondary')
               .addClass('btn-primary')
               .html('<i class="bi bi-plus"></i> 追加');
      }
      
      // 検索条件でリセット
      $(this).show();
    });
  });
}

// ページロード時の初期化（Turboのみ）
document.addEventListener("turbo:load", onLoad);