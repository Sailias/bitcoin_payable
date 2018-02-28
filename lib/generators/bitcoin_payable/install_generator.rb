require 'rails/generators'
require 'rails/generators/active_record'

module BitcoinPayable
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    desc 'Generates (but does not run) a migration to add a bitcoin payment tables.'

    def create_migration_file
      migration_template 'create_bitcoin_payments.rb', 'db/migrate/create_bitcoin_payments.rb', migration_version: migration_version
      migration_template 'create_bitcoin_payment_transactions.rb', 'db/migrate/create_bitcoin_payment_transactions.rb', migration_version: migration_version
      migration_template 'create_currency_conversions.rb', 'db/migrate/create_currency_conversions.rb', migration_version: migration_version
      migration_template 'add_btc_conversion_to_bitcoin_payments.rb', 'db/migrate/add_btc_conversion_to_bitcoin_payments.rb', migration_version: migration_version
      migration_template 'add_confirmations_block_n_to_btc_payment_transactions.rb', 'db/migrate/add_confirmations_block_n_to_btc_payment_transactions.rb', migration_version: migration_version
      migration_template 'add_crypto_to_bitcoin_payments.rb', 'db/migrate/add_crypto_to_bitcoin_payments.rb', migration_version: migration_version
      migration_template 'change_default_state_bitcoin_payments.rb', 'db/migrate/change_default_state_bitcoin_payments.rb', migration_version: migration_version
      migration_template 'add_crypto_and_change_name_btc_in_currency_conversions.rb', 'db/migrate/add_crypto_and_change_name_btc_in_currency_conversions.rb', migration_version: migration_version
    end

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number(dirname)
    end

    def rails5?
      Rails.version.start_with? '5'
    end

    def migration_version
      if rails5?
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end
    end

  end
end
