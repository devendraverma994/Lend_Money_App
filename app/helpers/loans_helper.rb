# app/helpers/loans_helper.rb
module LoansHelper
  def render_loan_actions_for_requested(loan)
    if current_user.admin?
      link_to('Approve', set_interest_rate_loan_path(loan), class: 'btn btn-primary btn-sm mr-2') +
      link_to('Reject', reject_loan_path(loan), data: { turbo_method: :patch }, class: 'btn btn-danger btn-sm ml-2')
    elsif current_user.user?
      link_to('Reject', reject_loan_path(loan), data: { turbo_method: :patch }, class: 'btn btn-danger btn-sm')
    end
  end

  def render_loan_actions_for_approved(loan)
    if current_user.admin?
      link_to('Reject', reject_loan_path(loan), data: { turbo_method: :patch }, class: 'btn btn-danger btn-sm')
    else
      link_to('Accept', accept_loan_path(loan), data: { turbo_method: :patch }, class: 'btn btn-success btn-sm mr-2') +
      link_to('Reject', reject_loan_path(loan), data: { turbo_method: :patch }, class: 'btn btn-danger btn-sm ml-2')
    end
  end

  def render_loan_actions_for_open(loan)
    link_to('Repay', repay_loan_path(loan), data: { turbo_method: :patch }, class: 'btn btn-info btn-sm') if current_user.user?
  end
end
