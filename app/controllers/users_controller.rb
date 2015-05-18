class UsersController < ApplicationController
  def show
    find_user
    @repositories = @user.github_repositories.source.order('stargazers_count DESC').limit(10)
    @favourite_projects = @user.favourite_projects.limit(10)
    @contributions = @user.github_contributions.with_repo
                          .joins(:github_repository)
                          .where('github_repositories.owner_id != ?', @user.github_id.to_s)
                          .where('github_repositories.fork = ?', false)
                          .includes(:github_repository)
                          .order('count DESC').limit(10)
  end

  def repositories
    find_user
    @repositories = @user.github_repositories.source.order('stargazers_count DESC').paginate(page: params[:page])
  end

  def contributions
    find_user
    @contributions = @user.github_contributions.with_repo
                          .joins(:github_repository)
                          .where('github_repositories.owner_id != ?', @user.github_id.to_s)
                          .where('github_repositories.fork = ?', false)
                          .includes(:github_repository)
                          .order('count DESC').paginate(page: params[:page])
  end

  private

  def find_user
    @user = GithubUser.visible.where("lower(login) = ?", params[:login].downcase).first
    @user = GithubOrganisation.where("lower(login) = ?", params[:login].downcase).first if @user.nil?
    raise ActiveRecord::RecordNotFound if @user.nil?
    redirect_to user_path(@user), :status => :moved_permanently if params[:login] != @user.login
  end
end
