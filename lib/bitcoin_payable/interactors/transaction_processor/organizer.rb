module BitcoinPayable::Interactors::TransactionProcessor
  class Organizer
    include Interactor::Organizer

    organize [
      BitcoinPayable::Interactors::TransactionProcessor::ProcessTransaction,
      BitcoinPayable::Interactors::TransactionProcessor::UpdatePaymentAmounts
    ]
  end
end