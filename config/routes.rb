Rails.application.routes.draw do
  get "dashboard/index"

  resources :transactions do
    collection do
      post :import
    end
  end

  resources :categories

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  post "/transactions/save_import", to: "transactions#save_import", as: "save_import_transactions"

end
