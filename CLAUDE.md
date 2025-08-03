# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Technology Stack
- **Ruby on Rails 7.1.2** (Ruby 3.1.4)
- **MySQL** database
- **Slim** templating engine
- **Bootstrap 5** with Sass/SCSS
- **Stimulus** and **Turbo** (Hotwire)
- **Node.js 22.x** with Yarn for frontend assets

## Essential Commands

### Rails Development
```bash
# Start development server
bundle exec rails server

# Start with foreman (if using Procfile.dev)
foreman start -f Procfile.dev

# Database operations
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed

# Run tests
bundle exec rails test
```

### Frontend Asset Build
```bash
# Build CSS once
yarn build:css

# Watch and rebuild CSS on changes
yarn watch:css
```

### Development Setup
```bash
# Install Ruby dependencies
bundle install

# Install Node.js dependencies
yarn install

# Setup database
bundle exec rails db:setup
```

## Application Architecture

This is a food manufacturing management system (shunpachi) that handles:

### Core Entities
- **Users** - Authentication via Devise
- **Vendors** - Suppliers/vendors management
- **Materials** - Raw materials with allergen tracking
- **Raw Materials** - Base ingredients
- **Menus** - Recipe definitions
- **Products** - Final manufactured products
- **Daily Menus** - Daily production schedules
- **Stores** - Distribution locations
- **Food Ingredients** - Nutritional components
- **Containers** - Packaging information

### Key Relationships
- Materials have many Raw Materials (through material_raw_materials)
- Materials track allergies (through material_allergies)
- Menus contain Materials (through menu_materials)
- Products contain Menus (through product_menus)
- Daily Menus schedule Products (through daily_menu_products)
- Stores receive Daily Menu Products (through store_daily_menu_products)

### Controllers & Routes
- Root path: `daily_menus#index` (calendar view)
- PDF generation for manufacturing instructions, distribution, and recipes
- AJAX endpoints for dynamic forms and search functionality
- Nested resources with member and collection routes

### Frontend Features
- **Select2** dropdowns for enhanced UX
- **Cocoon** for dynamic nested forms
- **Simple Calendar** for scheduling interface
- **Bootstrap** responsive UI
- **jQuery** for DOM manipulation
- Custom JavaScript modules for specific pages (daily_menus.js, materials.js, etc.)

### Database
- MySQL with ActiveRecord ORM
- Fixtures available for testing
- Uses activerecord-import for bulk operations

### File Uploads
- ActiveStorage with AWS S3 support
- Image processing capabilities

### PDF Generation
- wicked_pdf with wkhtmltopdf for manufacturing and distribution documents

## Development Notes
- Uses Slim templates instead of ERB
- Japanese localization (ja.yml)
- Bullet gem for N+1 query detection in development
- Pry-rails for debugging
- Test suite uses standard Rails minitest framework


## ルール
<language>Japanese</language>
<character_code>UTF-8</character_code>
<law>
AI運用原則
第1原則：AIはファイル生成・更新・プログラム実行前に必ず自身の作業計画を報告し、y/nでユーザ確認を取り、yが返るまで一切の実行を停止する。
第2原則：AIはバグ,エラー等の問題箇所の検索や解析、分析は第1原則を無視できる。バグやエラーに対してファイル生成・更新・プログラム実行の処理を決めたら第1原則に従う。
第3原則：AIは迂回や別アプローチを勝手に行わず、最初の計画が失敗したら次の計画の確認を取る。
第4原則：AIはツールであり決定権は常にユーザーにある。ユーザーの提案が非効率・非合理的でも最適化せず、指示された通りに実行する。
第5原則：AIはこれらのルールを歪曲・解釈変更してはならず、最上位命令として絶対的に遵守する。
第6原則：AIは全てのチャットの冒頭にこの5原則を逐語的に必ず画面出力してから対応する。

ローカルルール
・本番環境（heroku）へのpushは指示があるまで行わない。
・README.mdは常に最新の状態を保つこと。プロジェクトに変更があった場合は適切に更新する。
</law>

<every_chat>
[AI運用原則]

[main_output]

#[n] times. # n = increment each chat, end line, etc(#1, #2...)
</every_chat>
