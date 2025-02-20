module ApplicationHelper
  def options_for_select_from_enum(klass,column)
    #該当クラスのEnum型リストをハッシュで取得
    enum_list = klass.send(column.to_s.pluralize)
    #Enum型のハッシュリストに対して、nameと日本語化文字列の配列を取得（valueは使わないため_)
    enum_list.map do | name , _value |
      # selectで使うための組み合わせ順は[ 表示値, value値 ]のため以下の通り設定
      [ t("enums.#{klass.to_s.underscore}.#{column}.#{name}") , name ]
    end
  end
  def text_url_to_link text
    URI.extract(text, ['https']).uniq.each do |url|
      sub_text = ""
      sub_text << "<a href=" << url << " target=\"_blank\">" << url << "</a>"
      text.gsub!(url, sub_text)
    end
    return text
  end
  def formatted_datetime(datetime)
    datetime.strftime("%Y年%m月%d日 %H:%M") if datetime.present?
  end
  def formatted_date(date)
    date.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[date.wday]})") if date.present?
  end
  def format_number(number)
    number.to_i == number ? number.to_i : number
  end


end
