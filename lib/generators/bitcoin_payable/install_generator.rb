require 'rails/generators'
require 'rails/generators/active_record'

module BitcoinPayable
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    desc 'Generates (but does not run) a migration to add a bitcoin payment tables.'

    def copy_migrations
      copy_migration 'create_bitcoin_payments'
      copy_migration 'create_bitcoin_payment_transactions'
      copy_migration 'create_currency_conversions'
      copy_migration 'add_btc_conversion_to_bitcoin_payments'
      copy_migration 'add_block_height_to_bitcoin_payment_transactions'
    end

    private

    def copy_migration(filename)
      if self.class.migration_exists?("db/migrate", "#{filename}")
        say_status("skipped", "Migration #{filename}.rb already exists")
      else
        migration_template "#{filename}.rb", "db/migrate/#{filename}.rb"
      end
    end

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number(dirname)
    end
  end
end