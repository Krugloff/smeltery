#encoding: utf-8

require 'active_record'
require 'active_support/concern'

=begin
  Выполнение каждого теста в теле отдельной транзакции.

  Use: добавление модуля.
  P.S. модуль создан на основе ActiveRecord::TestFixtures.
=end
module Smeltery::TransactionalTests
  extend ActiveSupport::Concern

  included do
    setup :begin_transaction
    teardown :rollback_transaction

    class_attribute :use_transactional_tests
    self.use_transactional_tests = true
  end

  module ClassMethods
    # Метод вызывается непосредственно, для объявления тестов, уже использующих транзакции.
    def uses_transaction(*methods)
      @uses_transaction = [] unless defined?(@uses_transaction)
      @uses_transaction.concat methods.map { |m| m.to_s }
    end

    def uses_transaction?(method)
      @uses_transaction = [] unless defined?(@uses_transaction)
      @uses_transaction.include?(method.to_s)
    end
  end

  private

    def begin_transaction
      return if ActiveRecord::Base.configurations.blank?

      @test_connections = []

      if _run_in_transaction?
        @test_connections = _enlist_test_connections
        @test_connections.each do |connection|
          connection.increment_open_transactions
          connection.transaction_joinable = false
          connection.begin_db_transaction
        end
      end
    end

    def rollback_transaction
      return if ActiveRecord::Base.configurations.blank?

      if _run_in_transaction?
        @test_connections.each do |connection|
          if connection.open_transactions != 0
            connection.rollback_db_transaction
            connection.decrement_open_transactions
          end
        end
        @test_connections.clear
      end
      ActiveRecord::Base.clear_active_connections!
    end

    # method_name ссылается на имя текущего теста.
    def _run_in_transaction?
      use_transactional_tests && !self.class.uses_transaction?(method_name)
    end

    def _enlist_test_connections
      ActiveRecord::Base.connection_handler.connection_pools.values.map(&:connection)
    end
end