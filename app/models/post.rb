class Post < ApplicationRecord

  paginates_per 10

  validates :title, :body, presence: true, allow_blank: false

  default_scope { order('created_at DESC') }

end
