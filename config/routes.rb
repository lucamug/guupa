Guupa::Application.routes.draw do
  # mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'

  # The command ":area => /[^\/]*/" has been added because 
  # http://coding-journal.com/rails-3-routing-parameters-with-dots/

  # scope ":website/:area/:substatus", :website => /Idee|Ideas/i do # , :area => /[^\/]*/ do 
  scope ":website/:area", :website => /Idee|Ideas/i do # , :area => /[^\/]*/ do 
    get  "sign_in"                       => "connections#new",           :as => "sign_in"          
    get  "sign_out"                      => "connections#destroy",       :as => "sign_out"         
    get  "sign_out_all"                  => "connections#destroy_all",   :as => "sign_out_all"     

    get  "open/:id"                      => "comments#open",             :as => "open" 
    get  "close/:id"                     => "comments#close",            :as => "close" 
    get  "progress/:id"                  => "comments#progress",         :as => "progress" 
    
    get  "new_idea_step_1"               => "posts#new_idea_step_1",     :as => "new_idea_step_1" 
    get  "new_idea_step_2/:post_id"      => "posts#new_idea_step_2",     :as => "new_idea_step_2" 
    get  "new_idea/:post_id"             => "posts#new_idea",            :as => "new_idea" 
    get  "ideas/:id"                     => "posts#show_idea",           :as => "idea" 
    put  "vote/:id"                      => "posts#vote",                :as => "post_vote" 
    
    get  "users/:id/edit_password"       => "users#edit_password",       :as => "edit_user_password" 
    put  "users/:id/edit_password"       => "users#update_password",     :as => "update_user_password" 
    
    get  "users/:id/edit_email"          => "users#edit_email",          :as => "edit_user_email" 
    put  "users/:id/edit_email"          => "users#update_email",        :as => "update_user_email" 
    get  "users/:id/to_temporary"        => "users#to_temporary",        :as => "to_temporary"
    put  "users/:id/to_temporary_update" => "users#to_temporary_update", :as => "to_temporary_update"

    resources :posts,              :only => [:index, :show, :new, :create, :edit, :update          ]
    resources :users,              :only => [        :show,       :create, :edit, :update, :destroy]
    resources :votes,              :only => [:index,        :new, :create, :edit, :update          ]
    resources :connections,        :only => [:index,              :create,                         ]
    resources :comments,           :only => [:index, :show,       :create, :edit, :update, :destroy]
    resources :tags,               :only => [:index, :show,                :edit                   ]
    resources :messages,           :only => [:index, :show, :new, :create                          ]
    resources :password_resets,    :only => [               :new, :create, :edit, :update          ]
    resources :email_confirmation, :only => [               :new,          :edit                   ]

    match '/about',         :to => 'pages#about'
    match '/privacy',       :to => 'pages#privacy'
    match '/cookies_error', :to => 'pages#cookies_error'                               
    match '/help',          :to => 'pages#help'                                        
    match '/translations',  :to => 'pages#translations'                                        
    match '/:tag_1/:tag_2/:tag_3/:tag_4',         :to => 'posts#index_with_tags' # , :tag_1 => /[^\/]*/,  :tag_2 => /[^\/]*/,  :tag_3 => /[^\/]*/,  :tag_4 => /[^\/]*/
    match '/:tag_1/:tag_2/:tag_3',                :to => 'posts#index_with_tags' # , :tag_1 => /[^\/]*/,  :tag_2 => /[^\/]*/,  :tag_3 => /[^\/]*/
    match '/:tag_1/:tag_2',                       :to => 'posts#index_with_tags' # , :tag_1 => /[^\/]*/,  :tag_2 => /[^\/]*/
    match '/:tag_1',                              :to => 'posts#index_with_tags' # , :tag_1 => /[^\/]*/
    root :to => 'posts#index_with_tags', :as => :root
  end 
  # get  ":website/:area" => "posts#index", :as => :root_without_substatus
  get  ":website"       => "posts#index", :as => :root_without_area
  root :to              => 'posts#index', :as => :root_without_website
end

