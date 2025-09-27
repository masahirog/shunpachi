namespace :company do
  desc "新しい企業とその管理者ユーザーを作成する"
  task :create => :environment do
    # パラメータの取得
    name = ENV['name']
    subdomain = ENV['subdomain']
    email = ENV['email']
    password = ENV['password'] || 'password123'
    user_name = ENV['user_name'] || '管理者'

    # 必須パラメータの確認
    if name.blank? || subdomain.blank? || email.blank?
      puts "❌ エラー: 必須パラメータが不足しています"
      puts "使用方法:"
      puts "bundle exec rails company:create name=\"企業名\" subdomain=\"サブドメイン\" email=\"admin@example.com\""
      puts ""
      puts "オプションパラメータ:"
      puts "password=\"パスワード\" (デフォルト: password123)"
      puts "user_name=\"ユーザー名\" (デフォルト: 管理者)"
      exit 1
    end

    # サブドメインの形式チェック
    unless subdomain.match?(/\A[a-z0-9\-]+\z/)
      puts "❌ エラー: サブドメインは英数字とハイフンのみ使用可能です"
      exit 1
    end

    puts "=== 新しい企業の作成 ==="
    puts "企業名: #{name}"
    puts "サブドメイン: #{subdomain}"
    puts "管理者メール: #{email}"
    puts "管理者名: #{user_name}"
    puts ""

    # 確認
    print "この内容で作成しますか？ (y/n): "
    confirm = STDIN.gets.chomp.downcase
    unless ['y', 'yes'].include?(confirm)
      puts "キャンセルしました。"
      exit 0
    end

    begin
      ActiveRecord::Base.transaction do
        # 企業の作成
        puts "\n🏢 企業を作成中..."
        company = Company.create!(
          name: name,
          subdomain: subdomain
        )
        puts "✅ 企業作成成功: #{company.name} (ID: #{company.id})"

        # 管理者ユーザーの作成
        puts "\n👤 管理者ユーザーを作成中..."
        user = User.create!(
          email: email,
          password: password,
          password_confirmation: password,
          name: user_name,
          company: company
        )
        puts "✅ ユーザー作成成功: #{user.name} (#{user.email})"

        puts "\n🎉 企業とユーザーの作成が完了しました！"
        puts ""
        puts "=== 作成されたデータ ==="
        puts "企業ID: #{company.id}"
        puts "企業名: #{company.name}"
        puts "サブドメイン: #{company.subdomain}"
        puts "管理者ID: #{user.id}"
        puts "管理者名: #{user.name}"
        puts "管理者メール: #{user.email}"
        puts ""
        puts "=== ログイン情報 ==="
        puts "メールアドレス: #{user.email}"
        puts "パスワード: #{password}"
      end

    rescue ActiveRecord::RecordInvalid => e
      puts "❌ エラー: #{e.message}"
      puts "詳細:"
      if e.record.is_a?(Company)
        e.record.errors.full_messages.each { |msg| puts "  - 企業: #{msg}" }
      elsif e.record.is_a?(User)
        e.record.errors.full_messages.each { |msg| puts "  - ユーザー: #{msg}" }
      end
      exit 1
    rescue => e
      puts "❌ 予期しないエラーが発生しました: #{e.message}"
      exit 1
    end
  end

  desc "企業一覧を表示する"
  task :list => :environment do
    puts "=== 企業一覧 ==="
    Company.all.each do |company|
      puts "#{company.id}: #{company.name} (#{company.subdomain})"
      puts "  ユーザー数: #{company.users.count}"
      puts "  ベンダー数: #{company.vendors.count}"
      puts "  店舗数: #{company.stores.count}"
      puts "  日次献立数: #{company.daily_menus.count}"
      puts ""
    end
  end

  desc "企業の詳細情報を表示する"
  task :show => :environment do
    id = ENV['id']
    if id.blank?
      puts "❌ エラー: 企業IDを指定してください"
      puts "使用方法: bundle exec rails company:show id=1"
      exit 1
    end

    begin
      company = Company.find(id)
      puts "=== #{company.name} の詳細情報 ==="
      puts "ID: #{company.id}"
      puts "企業名: #{company.name}"
      puts "サブドメイン: #{company.subdomain}"
      puts "作成日: #{company.created_at.strftime('%Y/%m/%d %H:%M')}"
      puts ""
      puts "=== 関連データ ==="
      puts "ユーザー数: #{company.users.count}"
      puts "ベンダー数: #{company.vendors.count}"
      puts "店舗数: #{company.stores.count}"
      puts "日次献立数: #{company.daily_menus.count}"
      
      if company.users.any?
        puts ""
        puts "=== ユーザー一覧 ==="
        company.users.each do |user|
          puts "- #{user.name} (#{user.email})"
        end
      end
      
    rescue ActiveRecord::RecordNotFound
      puts "❌ エラー: ID #{id} の企業が見つかりません"
      exit 1
    end
  end
end