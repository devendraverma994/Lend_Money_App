require 'rails_helper'

RSpec.describe Loan, type: :model do
  let!(:admin) { User.create(email: 'admin@example.com', password: 'password', role: 'admin') }
  let!(:user) { User.create(email: 'user@example.com', password: 'password', role: 'user') }
  let!(:admin_wallet) { Wallet.create(user: admin, amount: 10000) }
  let!(:user_wallet) { Wallet.create(user: user, amount: 5000) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      loan = Loan.new(user: user, admin: admin, amount: 1000, interest_rate: 0.05, state: 'requested')
      expect(loan).to be_valid
    end

    it 'is not valid without an amount' do
      loan = Loan.new(user: user, admin: admin, interest_rate: 0.05, state: 'requested')
      expect(loan).not_to be_valid
      expect(loan.errors[:amount]).to include("can't be blank")
    end

    it 'is not valid with amount less than or equal to 0' do
      loan = Loan.new(user: user, admin: admin, amount: 0, interest_rate: 0.05, state: 'requested')
      expect(loan).not_to be_valid
      expect(loan.errors[:amount]).to include("must be greater than 0")
    end

    it 'is not valid with an invalid state' do
      loan = Loan.new(user: user, admin: admin, amount: 1000, interest_rate: 0.05, state: 'invalid')
      expect(loan).not_to be_valid
      expect(loan.errors[:state]).to include("is not included in the list")
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'belongs to admin' do
      association = described_class.reflect_on_association(:admin)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:class_name]).to eq 'User'
      expect(association.options[:foreign_key]).to eq 'admin_id'
    end
  end

  describe 'scopes' do
    describe '.open' do
      it 'returns loans with state open' do
        open_loan = Loan.create!(user: user, admin: admin, amount: 2000, interest_rate: 0.05, state: 'open')
        closed_loan = Loan.create!(user: user, admin: admin, amount: 1500, interest_rate: 0.05, state: 'closed')

        expect(Loan.open).to include(open_loan)
        expect(Loan.open).not_to include(closed_loan)
      end
    end
  end

  describe 'instance methods' do
    let(:loan) { Loan.new(user: user, admin: admin, amount: 1000, interest_rate: 0.05) }

    describe '#formatted_interest_rate' do
      it 'returns formatted interest rate' do
        expect(loan.formatted_interest_rate).to eq(5.0)
      end
    end

    describe '#interest_rate_from_percentage' do
      it 'sets interest rate from percentage' do
        loan.interest_rate_from_percentage(10.0)
        expect(loan.interest_rate).to eq(0.1)
      end
    end

    describe '#set_default_repay_amount' do
      it 'sets repay_amount to amount' do
        loan.set_default_repay_amount
        expect(loan.repay_amount).to eq(loan.amount)
      end
    end
  end
end
