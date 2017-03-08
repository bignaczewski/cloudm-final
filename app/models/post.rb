class Post < ApplicationRecord

  validates :title, :body, presence: true, allow_blank: false

end
