class LoansController < ApplicationController
  before_action :set_loan, only: [:show, :approve, :reject, :accept, :close, :set_interest_rate]
  before_action :authenticate_user!

  def index
    @loans = current_user.admin? ? Loan.all : current_user.loans
    @wallet = current_user.wallet
  end

  def new
    @loan = Loan.new
  end

  def create
    @loan = current_user.loans.new(loan_params)
    @loan.admin = User.find_by(role: 'admin')

    if @loan.save
      render :show, status: :created, location: @loan
    else
      render json: @loan.errors, status: :unprocessable_entity
    end
  end

  def show
  end

  def approve
    interest_rate_percentage = params[:loan][:interest_rate].to_f
    interest  = @loan.interest_rate_from_percentage(interest_rate_percentage)
    @loan.update(state: 'approved', admin: current_user, interest_rate: interest)
    redirect_to loan_path(@loan), notice: 'Loan approved successfully.'
  end

  def repay
    @loan = Loan.find(params[:id])
    @loan.repay!

    redirect_to @loan, notice: 'Loan successfully repaid.'
  rescue StandardError => e
    flash[:alert] = "Error repaying loan: #{e.message}"
    redirect_back(fallback_location: root_path)
  end

  def reject
    @loan.reject!
    redirect_to @loan, notice: 'Loan was successfully rejected.'
  end

  def accept
    @loan.open!
    redirect_to @loan, notice: 'Loan was successfully accepted and is now open.'
  end

  def set_interest_rate
    render 'set_interest_rate'
  end

  def close
    @loan.close!
    redirect_to @loan, notice: 'Loan was successfully closed.'
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end

  def loan_params
    params.require(:loan).permit(:amount)
  end
end
