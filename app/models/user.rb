class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create do
    Stripe::Customer.create(email: email)
  end

  def active?
    return false unless subscription_ends_at.present?
    subscription_ends_at > Time.zone.now
  end
end
