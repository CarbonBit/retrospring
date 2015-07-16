class SearchController < ApplicationController
  def search
    if params[:q].nil?
      @users = []
      @answers = []
      @questions = []
    else
      @users = User.search params[:q]
      @answers = Answer.search params[:q]
      @questions = Question.search params[:q]
    end
  end
end
