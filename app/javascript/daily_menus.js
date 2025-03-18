// daily_menus.js
$(document).ready(function() {
  // 商品追加ボタンのクリックイベント
  $(document).on('click', '.js-add-product-btn', function() {
    console.log('追加ボタンがクリックされました');
    const row = $(this).closest('tr');
    const productId = row.data('id');
    const productName = row.data('name');
    const category = row.data('category');
    const sellPrice = row.data('sell-price');
    const costPrice = row.data('cost-price');
    
    // 商品を献立に追加
    addProductToDailyMenu(productId, productName, category, sellPrice, costPrice);
    
    // モーダルを閉じない（複数の商品を追加しやすくするため）
    // $('#addProductModal').modal('hide');
  });
  
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
  
  // 日別献立に商品を追加する関数
  function addProductToDailyMenu(productId, productName, category, sellPrice, costPrice) {
    // 新しいIDを生成
    const newId = new Date().getTime();
    
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
        <td class="text-center">
          <input class="form-control form-control-sm js-manufacturing-number text-center" type="number" value="1" min="0" name="daily_menu[daily_menu_products_attributes][${newId}][manufacturing_number]">
        </td>
        <td class="text-center">
          <div class="d-flex align-items-center justify-content-center">
            <span class="badge bg-secondary me-1 js-store-distribution-badge">0</span>
            <button class="btn btn-sm btn-outline-primary js-store-distribution-item-btn" type="button" data-daily-menu-product-id="temp_${newId}">
              <i class="bi bi-pencil-square"></i>
            </button>
          </div>
        </td>
        <td class="text-center">
          <a class="btn btn-sm btn-outline-danger" data-confirm="削除してもよろしいですか？" rel="nofollow" data-method="delete" href="#">
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
  
  // 金額フォーマット関数
  function formatCurrency(amount) {
    return '¥' + Number(amount).toLocaleString();
  }
  
  // 製造数の変更イベント
  $(document).on('change', '.js-manufacturing-number', function() {
    updateTotals();
  });
  
  // 合計金額を計算する関数
  function updateTotals() {
    let totalSelling = 0;
    let totalCost = 0;
    let totalManufacturing = 0;
    
    $('.js-daily-menu-product-row').each(function() {
      const row = $(this);
      const sellPrice = parseFloat(row.data('sell-price')) || 0;
      const costPrice = parseFloat(row.data('cost-price')) || 0;
      const quantity = parseInt(row.find('.js-manufacturing-number').val()) || 0;
      
      totalSelling += sellPrice * quantity;
      totalCost += costPrice * quantity;
      totalManufacturing += quantity;
    });
    
    // 合計を表示
    $('.daily-menu-products-total-selling-price').text(formatCurrency(totalSelling));
    $('.daily-menu-products-total-cost-price').text(formatCurrency(totalCost));
    $('.daily-menu-products-total-manufacturing-number').text(totalManufacturing);
    
    // 基本情報の金額も更新
    $('.daily-menu-total-selling-price').val(totalSelling);
    $('.daily-menu-total-cost-price').val(totalCost);
    
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
  }
  
  // Toastrライブラリが読み込まれていない場合の簡易実装
  if (typeof toastr === 'undefined') {
    window.toastr = {
      success: function(message) {
        alert(message);
      },
      error: function(message) {
        alert('エラー: ' + message);
      }
    };
  }
});