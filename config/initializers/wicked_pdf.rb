# config/initializers/wicked_pdf.rb

# WickedPdf.config を WickedPdf.configure に変更する（非推奨警告を避けるため）
if Rails.env.production?
  WickedPdf.configure do |config|
    config.exe_path = '/app/bin/wkhtmltopdf'
    config.enable_local_file_access = true
    config.default_options = {
      page_size: 'A4',
      encoding: 'UTF-8'
    }
  end
else
  WickedPdf.configure do |config|
    # 開発環境での設定
    config.exe_path = '/Users/yamashitamasahiro/.rbenv/shims/wkhtmltopdf'
    config.enable_local_file_access = true
    
    # 開発環境でのフォント設定
    config.default_options = {
      page_size: 'A4',
      encoding: 'UTF-8',
      'font_name' => 'IPAexGothic'
    }
  end
end