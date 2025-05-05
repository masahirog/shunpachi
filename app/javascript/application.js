// 通常のインポート
import "jquery"
import "@popperjs/core"
import "bootstrap"
import "cocoon"
import "select2"
import "materials"
import "menus"
import "daily_menus"
// グローバル変数の設定
window.$ = window.jQuery = jQuery;
window.bootstrap = bootstrap;

document.addEventListener('DOMContentLoaded', function() {
  // jQuery UIが読み込まれているか確認
  if (typeof $.fn.sortable === 'undefined') {
    
    // jQuery UIのCSSを追加
    const cssLink = document.createElement('link');
    cssLink.rel = 'stylesheet';
    cssLink.href = 'https://cdn.jsdelivr.net/npm/jquery-ui@1.13.2/dist/themes/base/jquery-ui.min.css';
    document.head.appendChild(cssLink);
    
    // jQuery UI JSの追加
    const script = document.createElement('script');
    script.src = 'https://cdn.jsdelivr.net/npm/jquery-ui@1.13.2/dist/jquery-ui.min.js';
    script.onload = function() {
      
      // jQuery UIが読み込まれた後、sortableを初期化
      if ($.fn.sortable && $('#material-raw-materials').length > 0) {
        $("#material-raw-materials").sortable({
          items: "tr.nested-fields",
          handle: ".handle",
          axis: "y",
          update: function() {
            $('#material-raw-materials tr.nested-fields').each(function(index) {
              $(this).find('input[name*="position"]').val(index + 1);
            });
          }
        });
      }
    };
    document.head.appendChild(script);
  } else {
  }
});