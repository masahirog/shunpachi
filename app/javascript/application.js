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

// jQueryUIが利用可能かを確認
document.addEventListener('DOMContentLoaded', function() {
  if (typeof $.fn.sortable === 'undefined') {
    
    // jQuery UI CSSとJSの読み込み
    const cssLink = document.createElement('link');
    cssLink.rel = 'stylesheet';
    cssLink.href = 'https://cdn.jsdelivr.net/npm/jquery-ui@1.13.2/dist/themes/base/jquery-ui.min.css';
    document.head.appendChild(cssLink);
    
    const script = document.createElement('script');
    script.src = 'https://cdn.jsdelivr.net/npm/jquery-ui@1.13.2/dist/jquery-ui.min.js';
    script.onload = function() {
      // イベント発火でmaterials.jsのコードに通知
      document.dispatchEvent(new Event('jquery-ui-loaded'));
    };
    document.head.appendChild(script);
  }
});