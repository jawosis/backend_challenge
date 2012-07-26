BackendChallenge::Application.routes.draw do
  resources :games, :only => [:create, :show, :destroy]
  resources :users, :only => [:create, :show, :update, :destroy]
  get "leaderboard" => "users#leaderboard"
  post "games/:id/score" => "games#score"
  delete "games/:id/reset_point" => "games#reset_point"
  put "games/:id/end" => "games#finish"
  match "*path", :to => "application#routing_error"
end
