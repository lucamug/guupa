class Ability
  include CanCan::Ability
  def initialize(user)
    Util.my_log "Ability#initialize: #{caller[0]}"
    alias_action :index_with_tags,                   :to => :read   # For Post
    alias_action :show_idea,                         :to => :read   # For Post
    alias_action :new_idea, :new_idea_step_1, :new_idea_step_2, :to => :create # For Post
    alias_action :edit_email, :update_email,         :to => :update # For User
    alias_action :edit_password, :update_password,   :to => :update # For User


    # Everybody:

#    can :read, :all
    can :read, [Post, User]
    can :create, [User, Connection] # To allow anybody to Sign in or Sign on
    can :new_idea_step_1,    [Post] # ????
    can "vote_1", :all
    can "vote_3", :all
    can "vote_4", :all

    if user.guest? || user.temporary?
      can [:to_temporary, :to_temporary_update], User, :id => user.id # Guest can change himself to Temporary
    end


    if user.guest? || user.temporary? || user.registered?

      can :create, Post
      can :update, Post,    :user_id => user.id

      can :create, Comment
      can :update, Comment, :user_id => user.id
      can :remove, Comment, :user_id => user.id

      can :update, User,    :id      => user.id

      if user.temporary? || user.registered?
        if user.registered?
          can :destroy, User, :id => user.id
          if user.email_confirmed
            can "vote_2", :all # Only registered user with confirmed email can volunteer
            can :send, Message
          end
        end
      end
    end


    if user.admin?
      can :manage, :all
    end

#    can :index_with_tags, :all
#    can :manage, :all
#    if false
#      can :manage, :all
#    else
#      can :read, :all
#    end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
