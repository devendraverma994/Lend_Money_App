class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :wallet, dependent: :destroy
  has_many :loans, dependent: :destroy

  after_create :create_default_wallet

  enum role: { user: 0, admin: 1 }

  scope :admins, -> { where(role: :admin) }

  def debit(amount)
    wallet.debit(amount)
  end

  def credit(amount)
    wallet.credit(amount)
  end

  def user?
    role == 'user'
  end

  private

  def create_default_wallet
    initial_amount = self.admin? ? 1000000 : 10000
    Wallet.create(user: self, amount: initial_amount, role: self.admin? ? 'admin' : 'user')
  end
end
