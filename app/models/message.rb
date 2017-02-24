class Message

  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :email, :subject, :content

  validates :email,
    presence: true

  validates :subject,
    presence: true

  validates :content,
    presence: true

end