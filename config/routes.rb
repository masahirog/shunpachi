Rails.application.routes.draw do
  root "daily_menus#index" # トップページを日別メニュー一覧に設定
  devise_for :users

  # 公開用製品ページ（認証不要）
  get 'p/:public_id', to: 'public_products#show', as: 'public_product'

  # 企業情報・アカウント管理
  get 'profile', to: 'profiles#show'
  patch 'profile', to: 'profiles#update'

  resources :containers
  resources :vendors
  resources :materials do
    collection do
      get :search
    end
    member do
      get 'get_details'
    end
  end
  resources :menus do
    member do
      get :details
      get :copy
    end
  end
  resources :products do
    member do
      post :generate_raw_materials # 既存の商品用
      get :copy
      post :regenerate_public_id
    end

    collection do
      post :generate_raw_materials # 新規作成時用
    end
  end
  resources :raw_materials
  resources :daily_menus do
    member do
      post :distribute
    end
  end
  resources :stores
  resources :food_ingredients do
    collection do
      get :search
    end
  end
  get 'calendar', to: 'daily_menus#index', as: :calendar

  resources :pdfs do
    collection do
      get :manufacturing_instruction
      get :distribution_instruction
      get :product_recipe
      get :menu_recipe
    end
  end
end
