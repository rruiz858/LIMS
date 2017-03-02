class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role.blank?
      can :read, Bottle
      can :single_results, Bottle
      can :multiple_results, Bottle
      can :show_bottle_results, Bottle
      can :export_chemicals, Bottle
      can :open_bottle_file, Bottle
      can :show, CoaSummary
    elsif user.role.role_type == "admin"
      can :manage, :all
    elsif user.role.role_type == "chemadmin"
      can :read, :all
      can :update_all, Query
      can :manage, Bottle
      can :manage, Agreement
      can :manage, Contact
      can :manage, TaskOrder
      can :manage, BottlesDatatable
      can :manage, Comit
      can :manage, Coa
      can :manage, CoaUpload
      can :manage, Msd
      can :manage, MsdsUpload
      can :manage, CoaSummary
      can :manage, CoaSummaryFile
      can :manage, ShipmentFile
      can :manage, PlateDetail
      can :manage, VialDetail
      can :manage, Vendor
      can :manage, Order
      cannot :delete, Order
      can :manage, OrderComment
      can :manage, ChemicalList
      can :manage, SourceSubstance
    elsif user.role.role_type == "chemcurator"
      can :read, :all
      cannot :read, Query do |query|
        query.try(:show)
        query.try(:edit)
      end
      can :unblinded_vial, PlateDetail
      can :blinded_vial, PlateDetail
      can :unblided, PlateDetail
      can :blinded, PlateDetail
      can :single_results, Bottle
      can :manage, CoaSummary
      can :multiple_results, Bottle
      can :show_bottle_results, Bottle
      can :export_chemicals, Bottle
      can :open_bottle_file, Bottle
      can :view_files, Vendor
      can :jstree_data, Vendor
      can :open_file, Vendor
      can :address, Contact
    elsif user.role.role_type == "cor"
      can :manage, Order
      cannot :submit_order, Order
      cannot :order_return_patch, Order
      can :manage, OrderComment
      can :unblinded_vial, PlateDetail
      can :blinded_vial, PlateDetail
      can :unblinded, PlateDetail
      can :blinded, PlateDetail
      can :view_files, Vendor
      can :jstree_data, Vendor
      can :open_file, Vendor
      can :task_orders, Vendor
      can :addresses, Vendor
      can :states, Contact
      can :manage, Agreement
      cannot :new, Agreement
      cannot :destroy, Agreement
      can :manage, Contact
      cannot :destroy, Contact
      can :manage, ChemicalList
      can :manage, SourceSubstance
      can :single_results, Bottle
      can :multiple_results, Bottle
      can :show_bottle_results, Bottle
      can :export_chemicals, Bottle
      can :open_bottle_file, Bottle
      can :read, :all
      cannot :read, Query do |query|
        query.try(:show)
        query.try(:edit)
      end
    elsif user.role.role_type == "postdoc"
      can :unblinded_vial, PlateDetail
      can :blinded_vial, PlateDetail
      can :unblinded, PlateDetail
      can :blinded, PlateDetail
      can :view_files, Vendor
      can :jstree_data, Vendor
      can :open_file, Vendor
      can :address, Contact
      can :update, Order
      can :show_plate, Order
      can :order_overview, Order
      can :order_plate_detail, Order
      can :review_order, Order
      can :manage, ChemicalList
      can :manage, SourceSubstance
      can :single_results, Bottle
      can :multiple_results, Bottle
      can :show_bottle_results, Bottle
      can :export_chemicals, Bottle
      can :open_bottle_file, Bottle
      can :read, :all
      cannot :read, Query do |query|
        query.try(:show)
        query.try(:edit)
      end
    elsif user.role.role_type == "contractadmin"
      can :unblinded_vial, PlateDetail
      can :blinded_vial, PlateDetail
      can :unblinded, PlateDetail
      can :blinded, PlateDetail
      can :manage, Vendor
      can :manage, Agreement
      can :manage, Contact
      can :manage, TaskOrder
      can :single_results, Bottle
      can :multiple_results, Bottle
      can :show_bottle_results, Bottle
      can :export_chemicals, Bottle
      can :open_bottle_file, Bottle
      can :read, :all
      cannot :read, Query do |query|
        query.try(:show)
        query.try(:edit)
      end
    else
      user.empty?
      can :read, :all
      can :show, CoaSummary
    end
  end


  # Define abilities for the passed in user here. For example:
  #
  #   user ||= User.new # guest user (not logged in)
  #   if user.admin?
  #     can :manage, :all
  #   else
  #     can :read, :all
  #   end
  #
  # The first argument to `can` is the action you are giving the user
  # permission to do.
  # If you pass :manage it will apply to every action. Other common actions
  # here are :read, :create, :update and :destroy.
  #
  # The second argument is the resource the user can perform the action on.
  # If you pass :all it will apply to every resource. Otherwise pass a Ruby
  # class of the resource.
  #
  # The third argument is an optional hash of conditions to further filter the
  # objects.
  # For example, here the user can only update published articles.
  #
  #   can :update, Article, :published => true
  #
  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

end
