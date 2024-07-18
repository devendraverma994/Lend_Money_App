require 'rails_helper'

RSpec.describe Wallet, type: :model do
  let!(:user) { User.create(email: 'user@example.com', password: 'password') }
  let(:wallet) { Wallet.create(user: user, amount: 1000) }

  describe '#debit' do
    it 'subtracts the specified amount from wallet amount' do
      wallet.debit(500)
      expect(wallet.amount).to eq(500)
    end
  end

  describe '#credit' do
    it 'adds the specified amount to wallet amount' do
      wallet.credit(500)
      expect(wallet.amount).to eq(1500)
    end
  end
end
