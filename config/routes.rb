Rails.application.routes.draw do
  get 'bottles/single_results'
  post 'bottles/single_results'
  get 'bottles/multiple_results'
  post 'bottles/multiple_results'
  post 'update_control' => 'source_substances#update_control'
  get 'show_identifiers' => 'source_substances#show_identifiers'
  get 'show_bottle_results' => 'bottles#show_bottle_results'
  post  'table_types' => 'coa_summaries#table_types'
  post 'curate_coas' => 'coa_summaries#curate_coas'
  post 'coa_matches' => 'coa_summaries#coa_matches'
  match '/source_substances', to: 'source_substances#new', via: 'get'
  match '/source_substances', to: 'source_substances#create', via: 'post'
  resources :source_substances do
    collection { get :standard_replicates}
    member do
      get 'show_gsids'
      post 'update_gsid'
    end
  end
  resources :orders do
    member do
      get 'show_plate'
      get 'order_plate_detail'
      get 'order_overview'
      get 'order_comments_show'
      patch 'order_return_patch'
      post 'order_plate_detail'
      patch 'order_plate_detail'
      post 'review_order'
      patch 'submit_order'
      post 'export_order_file'
    end
    resources :order_comments, :only => :create do
      collection do
      get 'all_comments'
      end
    end
    resources :chemical_lists, :only => :show
  end

  resources :shipments_activities
  post 'shipment_files/create_external_shipment'
  get 'shipment_files/create_external_shipment'
  get "vendors/:vendor_id/task_orders" => "vendors#task_orders", :as => "tasks", :format => :json
  get "vendors/:vendor_id/addresses" => "vendors#addresses", :as => "addresses", :format => :json
  get "contacts/:country/states" => "contacts#states", :as => "states", :format => :json
  match "vendors/:vendor_id/view_shipments" => "vendors#view_shipments", :as => "view_shipments", via: [:get]
  match '/jstree_data', :to => 'vendors#jstree_data', :as => 'jstree_data', via: [:get]
  match '/open_file', :to => 'vendors#open_file', :as => 'open_file', via: [:get]
  resources :shipment_files do
    member do
        get :add_bottles
        post :add_bottles
        get :show_plate
        get :finalize_plate
        post :finalize_plate
    end
    resources :plate_details do
      collection do
        get :blinded
        get :unblinded
        get :blinded_vial
        get :unblinded_vial
      end
    end
  end
  get "shipment_files/:shipment_file_id/vial_detail/:vial_detail_id" => "plate_details#show_vial", :as => "show_vial"
  match "shipment_files/:shipment_file_id/edit_record/:record_id" => "shipment_files#edit_record", :as => "edit_record", via: [:get,:post]
  match "comits/:comit_id/file_error/:file_error_id" => "comits#comit_error", :as => "comit_error", via: [:get]
  match "coa_summary_files/:coa_summary_file_id/file_error/:file_error_id" => "coa_summary_files#coa_summary_file_error", :as => "coa_summary_file_error", via: [:get]
  resources :coa_summary_files, :only => [:new, :create, :show, :destroy]
  resources :coa_summaries, :only => [:index, :show] do
    collection { get :uncurated_counts}
    collection { get :total_uncurated_count}
    member do
      get 'show_gsids'
      post 'add_gsid'
      get 'override_show'
      post 'override_gsid'
    end
  end
  resources :vendors do
    collection { post :move }
    collection { get :view_files}
    member do
      get :new_clone
    end
    resources :contacts do
      member do
        get :address
      end
    end
    resources :agreements do
      member do
        get :manage_agreements
        post :add_documents
        get :generate_pdf
        post :finalize_agreement
      end
      resources :task_orders
    end
  end
  get 'agreements' => 'agreements#index'
  resources :msds, :only => [:new, :index, :create,:destroy]
  resources :coas, :only => [:new, :create, :index, :destroy]
  resources :queries, :only => [:new, :create, :show, :edit, :update] do
    collection { post :update_all}
  end
  resources :activities
  devise_scope :user do
    get "/users/sign_up", :to => redirect("/")
  end
  devise_for :users
  resources :users, except: :create do
    collection {post :create_mentor_postdoc}
  end

  post 'create_user' => 'users#create', as: :create_user
  match '/open_bottle_file', :to => 'bottles#open_bottle_file', :as => 'open_bottle_file', via: [:get]
  resources :bottles do
    collection { post :export_chemicals}
    member do
      patch :edit_external_bottle
      post :edit_external_bottle
      get :edit_external_bottle
    end
  end
  get 'welcome/index'
  resources :welcome
  resources :comits


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'welcome#index'

  # Example of regular route:
  #  get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  root 'welcome#index'
end
