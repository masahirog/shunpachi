// テキストエリアの高さを自動調整する関数
function autoResizeTextarea(textarea) {
  // 最小高さを設定（初期のrows属性の高さを保持）
  if (!textarea.dataset.minHeight) {
    // 現在のスタイルを一時保存
    const currentHeight = textarea.style.height;

    // rows属性から最小高さを計算
    const rows = parseInt(textarea.getAttribute('rows')) || 3;
    const lineHeight = parseInt(window.getComputedStyle(textarea).lineHeight) || 24;
    const paddingTop = parseInt(window.getComputedStyle(textarea).paddingTop) || 0;
    const paddingBottom = parseInt(window.getComputedStyle(textarea).paddingBottom) || 0;
    const borderTop = parseInt(window.getComputedStyle(textarea).borderTopWidth) || 0;
    const borderBottom = parseInt(window.getComputedStyle(textarea).borderBottomWidth) || 0;

    textarea.dataset.minHeight = (rows * lineHeight) + paddingTop + paddingBottom + borderTop + borderBottom;

    // スタイルを戻す
    textarea.style.height = currentHeight;
  }

  // 一旦最小高さにリセット
  textarea.style.height = 'auto';
  textarea.style.height = textarea.dataset.minHeight + 'px';

  // スクロール高さを取得（実際のコンテンツの高さ）
  const scrollHeight = textarea.scrollHeight;

  // 1行分の高さを取得（line-heightから）
  const lineHeight = parseInt(window.getComputedStyle(textarea).lineHeight) || 24;

  // コンテンツの高さ + 1行分の余裕を持たせる
  const newHeight = Math.max(scrollHeight + lineHeight, parseInt(textarea.dataset.minHeight));

  // 高さを設定
  textarea.style.height = newHeight + 'px';
}

// 初期化関数
function initAutoResizeTextareas() {
  // auto-resizeクラスを持つすべてのテキストエリアを取得
  const textareas = document.querySelectorAll('textarea.auto-resize');

  textareas.forEach(textarea => {
    // すでに初期化済みの場合はスキップ（重複初期化を防ぐ）
    if (textarea.dataset.autoResizeInitialized === 'true') {
      // 既存の値がある場合は高さを再調整
      if (textarea.value) {
        autoResizeTextarea(textarea);
      }
      return;
    }

    // 初期化済みフラグを設定
    textarea.dataset.autoResizeInitialized = 'true';

    // オーバーフローを隠す
    textarea.style.overflow = 'hidden';
    textarea.style.resize = 'none'; // リサイズハンドルを非表示

    // 初期サイズを設定（既存の値がある場合も考慮）
    // タイムアウトで確実にレンダリング後に実行
    setTimeout(() => {
      autoResizeTextarea(textarea);
    }, 0);

    // inputイベントで自動リサイズ
    textarea.addEventListener('input', function() {
      autoResizeTextarea(this);
    });

    // フォーカス時にも調整
    textarea.addEventListener('focus', function() {
      autoResizeTextarea(this);
    });

    // ペースト時の処理
    textarea.addEventListener('paste', function() {
      setTimeout(() => autoResizeTextarea(this), 0);
    });
  });
}

// ページロード時とTurbo使用時の初期化
document.addEventListener('DOMContentLoaded', initAutoResizeTextareas);
document.addEventListener('turbo:load', initAutoResizeTextareas);

// Turboでのページ遷移完了後も再調整（editページ等で重要）
document.addEventListener('turbo:frame-load', initAutoResizeTextareas);
document.addEventListener('turbo:render', function() {
  setTimeout(initAutoResizeTextareas, 100);
});

// 動的に追加されたテキストエリアにも対応（Cocoon等）
document.addEventListener('cocoon:after-insert', function() {
  setTimeout(initAutoResizeTextareas, 100);
});

// エクスポート
export { autoResizeTextarea, initAutoResizeTextareas };