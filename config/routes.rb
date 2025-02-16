Rails.application.routes.draw do
  root "daily_menus#index" # トップページを日別メニュー一覧に設定
  devise_for :users

  resources :vendors
  resources :materials
  resources :menus
  resources :products
  resources :food_additives
  resources :food_ingredients
  resources :daily_menus
  resources :stores

  # simple_calendar 用のルート
  get 'calendar', to: 'daily_menus#index', as: :calendar
end
