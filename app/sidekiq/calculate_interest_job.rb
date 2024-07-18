class CalculateInterestJob
  include Sidekiq::Job

  def perform
    Loan.open.each do |loan|
      interest = loan.amount * (loan.formatted_interest_rate / 100.0) * (5.0 / (365 * 24 * 60))

      total_repay_amount = loan.repay_amount + interest

      loan.update!(repay_amount: total_repay_amount)
    end
  end
end
