# http://blog.arkency.com/2015/11/simple-feature-toggle-for-rails-app
#
=begin 

# define a feature:
FT = FeatureToggle.new.tap do |ft|
  ft.for(:new_user_profile) do |user_id:|
    Admin.where(user_id: user_id).exists?
  end
end

# use a feature; example in a rails controller
class UserProfilesController < ApplicationController
  def show
    FT.with(:new_user_profile, user_id: current_user.id) do
      return render :new_user_profile, locals: { user: NewUserProfilePresenter.new(current_user) }
    end

    render :show, locals: { user: UserProfilePresenter.new(current_user) }
  end
end

=end


class FeatureToggle
  def initialize
    @flags = Hash.new
  end

  def with(name, *args, &block)
    block.call if on?(name, *args)
  end

  def on?(name, *args)
    @flags.fetch(name, proc{|*_args| false }).call(*args)
  end

  def for(name, &block)
    @flags[name] = block
  end
end # class FeatureToggle
