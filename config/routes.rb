Rails.application.routes.draw do
  root "daily_menus#index" # トップページを日別メニュー一覧に設定
  devise_for :users

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
  resources :products
  resources :food_additives
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
end
