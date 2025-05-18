Rails.application.routes.draw do
  root "daily_menus#index" # トップページを日別メニュー一覧に設定
  devise_for :users

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
    end
  end
  resources :products do
    member do
      post :generate_raw_materials # 既存の商品用
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
    end
  end
end
