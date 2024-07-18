class LoanRepaymentJob
  include Sidekiq::Job

  def perform
    Loan.open.each do |loan|
      total_to_repay = loan.total_repay_amount
      if loan.user.wallet.amount <= total_to_repay
        loan.repay!
      end
    end
  end
end