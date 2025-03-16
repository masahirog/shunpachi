Rails.application.routes.draw do
  root "daily_menus#index" # トップページを日別メニュー一覧に設定
  devise_for :users

  resources :vendors
  resources :materials do
    collection do
      get :search
    end
  end
  resources :menus
  resources :products
  resources :food_additives
  resources :daily_menus
  resources :stores
  resources :food_ingredients do
    collection do
      get :search
    end
  end
  get 'calendar', to: 'daily_menus#index', as: :calendar
end
