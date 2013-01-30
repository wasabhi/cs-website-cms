CsWebsiteCms::Application.routes.draw do

  get 'faq', to: 'protected#index'
  get 'help', to: 'protected#index'
  get 'account', to: 'protected#index'
  get 'blog', to: 'protected#index'
  get 'forgot_password', to: 'protected#index'

  resources :authentications

  get 'protected', to: 'protected#index'

  match '/auth/:provider/callback', to: 'authentications#callback'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations'
  } do 
    match '/users/registrations/new_third_party', to: 'users/registrations#new_third_party', :as => 'new_third_party_user_registration' 
  end

  get 'members/search'
  get 'forums', to: 'members#forums'
  get '/community', to: 'members#community'
  get '/leaderboard', to: 'members#leaderboard'
  resources :members, only: [:index, :show, :update] do
    member do
      get 'challenges'
      get 'payments'
      get 'recommendations'
      match 'recommendations' => 'members#create_recommendations', via: [:post]
    end
  end

  get 'challenges/closed'
  get 'challenges/recent'
  get 'challenges/search'
  resources :challenges, only: [:index, :create, :show, :update] do
    member do
      get 'comments'
      get 'registrants'
    end

    resource :submission, only: [:show, :update] do
      resources :deliverables, only: [:create, :update, :destroy] do
        collection do
          post "upload"
        end
      end
    end
  end

  namespace :admin do
    resources :challenges, only: [:index, :new, :create, :edit, :update] # remove the restrictions once the new challenges are up
    post 'challenges/assets'
  end

  match "leaderboards" => "leaderboards#index"
  match "leaderboards/leaders" => "leaderboards#leaders", as: "leaders"

  match "/tos" => redirect("http://content.cloudspokes.com/terms-of-service")
  match "/signup" => redirect("/users/sign_up")
  match "/signin" => redirect("/users/sign_in")
  match "/login" => redirect("/users/sign_in")

  root to: 'refinery/pages#home'

  mount_sextant if Rails.env.development? # https://github.com/schneems/sextant

  # This line mounts Refinery's routes at the root of your application.
  # This means, any requests to the root URL of your application will go to Refinery::PagesController#home.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Refinery relies on it being the default of "refinery"
  mount Refinery::Core::Engine, :at => '/'

end
