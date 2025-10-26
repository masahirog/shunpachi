require 'google/apis/sheets_v4'
require 'googleauth'

class GoogleSheetsService
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

  def initialize
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.authorization = authorize
  end

  # スプレッドシートにメニューの原価を書き出す
  def export_menu_costs(spreadsheet_id:, sheet_name:, url_column:)
    return { success: false, error: 'スプレッドシートIDが設定されていません' } if spreadsheet_id.blank?
    return { success: false, error: 'シート名が設定されていません' } if sheet_name.blank?
    return { success: false, error: 'URL列が設定されていません' } if url_column.blank?

    begin
      # 指定された列（メニューURL）を読み取る
      range = "#{sheet_name}!#{url_column}:#{url_column}"
      response = @service.get_spreadsheet_values(spreadsheet_id, range)
      values = response.values

      return { success: false, error: 'スプレッドシートにデータがありません' } unless values

      updates = []
      updated_count = 0

      # 次の列を計算（例: D → E, Z → AA）
      next_column = next_column_letter(url_column)

      values.each_with_index do |row, index|
        next if row.empty? || row[0].nil?

        url = row[0].to_s.strip
        # URLからメニューIDを抽出（例: https://shunpachi-6720cdfee6d2.herokuapp.com/menus/64/）
        match = url.match(/\/menus\/(\d+)/)
        next unless match

        menu_id = match[1].to_i
        menu = Menu.find_by(id: menu_id)
        next unless menu

        # 次の列に原価を書き込むためのデータを準備
        row_number = index + 1
        updates << {
          range: "#{sheet_name}!#{next_column}#{row_number}",
          values: [[menu.cost_price.to_f.round(1)]]
        }
        updated_count += 1
      end

      # バッチで更新
      if updates.any?
        batch_update_values(spreadsheet_id, updates)
        { success: true, updated_count: updated_count, message: "#{updated_count}件のメニュー原価を更新しました" }
      else
        { success: false, error: '更新対象のメニューが見つかりませんでした' }
      end

    rescue Google::Apis::ClientError => e
      { success: false, error: translate_google_api_error(e) }
    rescue Google::Apis::Error => e
      { success: false, error: translate_google_api_error(e) }
    rescue StandardError => e
      { success: false, error: "エラーが発生しました: #{e.message}" }
    end
  end

  private

  def authorize
    # 環境変数からJSON形式の認証情報を取得
    credentials_json = ENV['GOOGLE_CREDENTIALS_JSON']

    unless credentials_json
      raise 'GOOGLE_CREDENTIALS_JSON環境変数が設定されていません'
    end

    # JSON文字列から認証情報を作成
    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(credentials_json),
      scope: SCOPE
    )

    credentials
  rescue JSON::ParserError => e
    raise "認証情報のJSON形式が不正です: #{e.message}"
  end

  def batch_update_values(spreadsheet_id, updates)
    batch_update_values_request_object = Google::Apis::SheetsV4::BatchUpdateValuesRequest.new(
      value_input_option: 'USER_ENTERED',
      data: updates.map do |update|
        Google::Apis::SheetsV4::ValueRange.new(
          range: update[:range],
          values: update[:values]
        )
      end
    )

    @service.batch_update_values(
      spreadsheet_id,
      batch_update_values_request_object
    )
  end

  # 列文字を次の列文字に変換（A → B, Z → AA, AA → AB など）
  def next_column_letter(column)
    column = column.upcase
    # 列文字を数値に変換
    num = 0
    column.each_char do |char|
      num = num * 26 + (char.ord - 'A'.ord + 1)
    end
    # 次の列の数値
    num += 1
    # 数値を列文字に変換
    result = ''
    while num > 0
      num -= 1
      result = ((num % 26) + 'A'.ord).chr + result
      num /= 26
    end
    result
  end

  # Google APIエラーを日本語メッセージに変換
  def translate_google_api_error(error)
    case error.status_code
    when 404
      if error.message.include?('Unable to parse range')
        '指定されたシート名が見つかりません。シート名を確認してください'
      else
        '指定されたスプレッドシートが見つかりません。スプレッドシートIDを確認してください'
      end
    when 403
      if error.message.include?('PERMISSION_DENIED')
        'スプレッドシートへのアクセス権限がありません。サービスアカウント（' +
        (JSON.parse(ENV['GOOGLE_CREDENTIALS_JSON'])['client_email'] rescue 'サービスアカウント') +
        '）に編集権限を付与してください'
      else
        'スプレッドシートへのアクセスが拒否されました。権限を確認してください'
      end
    when 400
      if error.message.include?('Unable to parse range')
        '指定された範囲が不正です。シート名やURL列の指定を確認してください'
      else
        'リクエストの形式が不正です。入力内容を確認してください'
      end
    when 401
      '認証に失敗しました。サービスアカウントの設定を確認してください'
    when 429
      'リクエスト数の上限に達しました。しばらく待ってから再度お試しください'
    when 500, 502, 503
      'Google側で一時的なエラーが発生しています。しばらく待ってから再度お試しください'
    else
      "Google APIエラー (#{error.status_code}): #{error.message}"
    end
  end
end
