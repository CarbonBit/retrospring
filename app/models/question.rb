require 'elasticsearch/model'

class Question < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :inboxes, dependent: :destroy

  validates :content, length: { maximum: 255 }

  before_destroy do
    rep = Report.where(target_id: self.id, type: 'Reports::Question')
    rep.each do |r|
      unless r.nil?
        r.deleted = true
        r.save
      end
    end

    user.decrement! :asked_count unless self.author_is_anonymous
  end

  def can_be_removed?
    return false if self.answers.count > 0
    return false if Inbox.where(question: self).count > 1
    true
  end

  def self.search(query)
    __elasticsearch__.search(
        {
            query: {
                multi_match: {
                    query: query,
                    fields: ['content^10', 'user']
                }
            }
        }
    )
  end
end

Question.import
