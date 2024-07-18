require 'rails_helper'

RSpec.describe LoansController, type: :controller do
  let!(:admin) { User.create!(email: 'admin@example.com', password: 'password', role: 'admin') }
  let!(:user) { User.create!(email: 'user@example.com', password: 'password', role: 'user') }
  let!(:wallet) { Wallet.create!(user: user, amount: 1000) }
  let!(:loan) { Loan.create!(user: user, admin: admin, amount: 1000, interest_rate: 0.05, state: 'requested') }

  before do
    sign_in user
  end

  describe 'GET #index' do
    context 'when user is admin' do
      before do
        sign_out user
        sign_in admin
        get :index
      end

      it 'assigns all loans to @loans' do
        expect(assigns(:loans)).to eq([loan])
      end
    end

    context 'when user is not admin' do
      before do
        get :index
      end

      it 'assigns user loans to @loans' do
        expect(assigns(:loans)).to eq([loan])
      end 
    end
  end

  describe 'GET #new' do
    before do
      get :new
    end

    it 'assigns a new loan to @loan' do
      expect(assigns(:loan)).to be_a_new(Loan)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new loan' do
        expect {
          post :create, params: { loan: { amount: 1000, interest_rate: 0.05 } }
        }.to change(Loan, :count).by(1)
      end

      it 'assigns the newly created loan to @loan' do
        post :create, params: { loan: { amount: 1000, interest_rate: 0.05 } }
        expect(assigns(:loan)).to be_a(Loan)
        expect(assigns(:loan)).to be_persisted
      end

      it 'renders the show template' do
        post :create, params: { loan: { amount: 1000, interest_rate: 0.05 } }
        expect(response).to render_template(:show)
      end

      it 'returns a success status' do
        post :create, params: { loan: { amount: 1000, interest_rate: 0.05 } }
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'does not create a new loan' do
        expect {
          post :create, params: { loan: { amount: nil, interest_rate: 0.05 } }
        }.not_to change(Loan, :count)
      end

      it 'returns an unprocessable entity status' do
        post :create, params: { loan: { amount: nil, interest_rate: 0.05 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #approve' do
    it 'updates the loan state to approved' do
      patch :approve, params: { id: loan.id, loan: { interest_rate: 5 } }
      loan.reload
      expect(loan.state).to eq('approved')
    end

    it 'redirects to the loan show page' do
      patch :approve, params: { id: loan.id, loan: { interest_rate: 5 } }
      expect(response).to redirect_to(loan_path(loan))
    end

    it 'sets a notice flash message' do
      patch :approve, params: { id: loan.id, loan: { interest_rate: 5 } }
      expect(flash[:notice]).to eq('Loan approved successfully.')
    end
  end

  describe 'PATCH #repay' do
    it 'repays the loan' do
      expect_any_instance_of(Loan).to receive(:repay!)
      patch :repay, params: { id: loan.id }
    end

    it 'redirects to the loan show page with a notice on successful repayment' do
      patch :repay, params: { id: loan.id }
      expect(response).to redirect_to(loan_path(loan))
      expect(flash[:notice]).to eq('Loan successfully repaid.')
    end
  end

  describe 'PATCH #reject' do
    it 'rejects the loan' do
      patch :reject, params: { id: loan.id }
      loan.reload
      expect(loan.state).to eq('rejected')
    end

    it 'redirects to the loan show page with a notice' do
      patch :reject, params: { id: loan.id }
      expect(response).to redirect_to(loan_path(loan))
      expect(flash[:notice]).to eq('Loan was successfully rejected.')
    end
  end

  describe 'PATCH #accept' do
    it 'accepts the loan and sets state to open' do
      patch :accept, params: { id: loan.id }
      loan.reload
      expect(loan.state).to eq('open')
    end

    it 'redirects to the loan show page with a notice' do
      patch :accept, params: { id: loan.id }
      expect(response).to redirect_to(loan_path(loan))
      expect(flash[:notice]).to eq('Loan was successfully accepted and is now open.')
    end
  end

  describe 'GET #set_interest_rate' do
    it 'renders the set interest rate template' do
      get :set_interest_rate, params: { id: loan.id }
      expect(response).to render_template('set_interest_rate')
    end
  end

  describe 'PATCH #close' do
    it 'closes the loan' do
      patch :close, params: { id: loan.id }
      loan.reload
      expect(loan.state).to eq('closed')
    end

    it 'redirects to the loan show page with a notice' do
      patch :close, params: { id: loan.id }
      expect(response).to redirect_to(loan_path(loan))
      expect(flash[:notice]).to eq('Loan was successfully closed.')
    end
  end
end
