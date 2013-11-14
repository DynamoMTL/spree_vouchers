Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :vouchers
  end
end
