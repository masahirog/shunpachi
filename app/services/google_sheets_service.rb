require 'google/apis/sheets_v4'
require 'googleauth'

class GoogleSheetsService
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

  def initialize
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.authorization = authorize
    @spreadsheet_id = ENV['GOOGLE_SPREADSHEET_ID']
    @sheet_name = ENV['GOOGLE_SHEET_NAME'] || 'Sheet1'
  end

  # スプレッドシートにメニューの原価を書き出す
  def export_menu_costs
    return { success: false, error: 'スプレッドシートIDが設定されていません' } unless @spreadsheet_id

    begin
      # D列（メニューURL）を読み取る（シート名を含む）
      range = "#{@sheet_name}!D:D"
      response = @service.get_spreadsheet_values(@spreadsheet_id, range)
      values = response.values

      return { success: false, error: 'スプレッドシートにデータがありません' } unless values

      updates = []
      updated_count = 0

      values.each_with_index do |row, index|
        next if row.empty? || row[0].nil?

        url = row[0].to_s.strip
        # URLからメニューIDを抽出（例: https://shunpachi-6720cdfee6d2.herokuapp.com/menus/64/）
        match = url.match(/\/menus\/(\d+)/)
        next unless match

        menu_id = match[1].to_i
        menu = Menu.find_by(id: menu_id)
        next unless menu

        # E列に原価を書き込むためのデータを準備（シート名を含む）
        row_number = index + 1
        updates << {
          range: "#{@sheet_name}!E#{row_number}",
          values: [[menu.cost_price.to_f.round(1)]]
        }
        updated_count += 1
      end

      # バッチで更新
      if updates.any?
        batch_update_values(updates)
        { success: true, updated_count: updated_count, message: "#{updated_count}件のメニュー原価を更新しました" }
      else
        { success: false, error: '更新対象のメニューが見つかりませんでした' }
      end

    rescue Google::Apis::Error => e
      { success: false, error: "Google API エラー: #{e.message}" }
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

  def batch_update_values(updates)
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
      @spreadsheet_id,
      batch_update_values_request_object
    )
  end
end
