class Loan < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User', foreign_key: 'admin_id'

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :state, presence: true, inclusion: { in: %w[requested approved open closed rejected] }
  validates :interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_initial_values
  before_create :set_default_repay_amount

  scope :open, -> { where(state: 'open') }

  def formatted_interest_rate
    (interest_rate * 100).round(2)
  end

  def interest_rate_from_percentage(percentage)
    self.interest_rate = percentage.to_f / 100
  end

  def requested?
    state == 'requested'
  end

  def approve?
    state == 'approved'
  end

  def open?
    state == 'open'
  end

  def close!
    update(state: 'closed')
  end

  def reject!
    update(state: 'rejected')
  end

  def set_default_repay_amount
    self.repay_amount = self.amount
  end

  def open!
    Loan.transaction do
      admin = User.find_by(role: 'admin')
      raise 'Admin not found' unless admin

      admin_wallet = admin.wallet
      user_wallet = user.wallet

      if admin_wallet.amount >= amount
        admin_wallet.debit(amount)
        user_wallet.credit(amount)
        update!(state: 'open')
      else
        raise 'Insufficient funds in admin wallet'
      end
    end
  end

  def repay!
    Loan.transaction do
      total_to_repay = total_repay_amount
      user_wallet = user.wallet
      admin_wallet = admin.wallet

      if user_wallet.amount >= total_to_repay
        perform_full_repayment(user_wallet, admin_wallet, total_to_repay)
      else
        perform_partial_repayment(user_wallet, admin_wallet)
      end 
    end
  end

  def total_repay_amount
    open? ? self.repay_amount : 0
  end

  private

  def set_initial_values
    self.state ||= 'requested'
    self.interest_rate ||= 0.05
  end

  def perform_full_repayment(user_wallet, admin_wallet, total_to_repay)
    user_wallet.decrement!(:amount, total_to_repay)
    admin_wallet.increment!(:amount, total_to_repay)
    update(state: 'closed')
  end

  def perform_partial_repayment(user_wallet, admin_wallet)
    partial_amount = user_wallet.amount
    user_wallet.decrement!(:amount, partial_amount)
    admin_wallet.increment!(:amount, partial_amount)
    update(state: 'closed')
  end
end
