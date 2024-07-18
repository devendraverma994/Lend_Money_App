class Wallet < ApplicationRecord
  belongs_to :user

  def debit(amount)
    self.amount -= amount
    save!
  end

  def credit(amount)
    self.amount += amount
    save!
  end
end
