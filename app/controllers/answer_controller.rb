class AnswerController < ApplicationController
  skip_before_filter :check_locale, only: [:embed]
  skip_before_filter :banned?, only: [:embed]

  def show
    @answer = Answer.find(params[:id])
    @display_all = true

    if user_signed_in?
      notif = Notification.where(target_type: "Answer", target_id: @answer.id, recipient_id: current_user.id, new: true).first
      unless notif.nil?
        notif.new = false
        notif.save
      end
      notif = Notification.where(target_type: "Comment", target_id: @answer.comments.pluck(:id), recipient_id: current_user.id, new: true)
      notif.update_all(new: false) unless notif.empty?
      notif = Notification.where(target_type: "Smile", target_id: @answer.smiles.pluck(:id), recipient_id: current_user.id, new: true)
      notif.update_all(new: false) unless notif.empty?
      # @answer.comments.smiles throws
      notif = Notification.where(target_type: "CommentSmile", target_id: @answer.comment_smiles.pluck(:id), recipient_id: current_user.id, new: true)
      notif.update_all(new: false) unless notif.empty?
    end
  end

  def embed
    @answer = Answer.find(params[:id])
    @display_all = true
    I18n.locale = 'en'
    render layout: 'embed'
  end
end
