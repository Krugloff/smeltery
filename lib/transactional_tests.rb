#encoding: utf-8

require 'active_record'
require 'active_support/concern'

module Smeltery
  # Этот модуль создан с использованием Rails fixtures. Пока он не используется библиотекой, но будет делать это в дальнейшем.
  # Task: выполнение каждого теста в теле отдельной транзакции.
  #
  # Use:
  # + require 'smeltery'
  # + include Smeltery::TransactionalTests
  # Require: ActiveRecord
  # P.S. модуль создан на основе ActiveRecord::TestFixtures.
  module TransactionalTests
    extend ActiveSupport::Concern

    included do
      setup :begin_transaction
      teardown :rollback_transaction

      class_attribute :use_transactional_tests
      self.use_transactional_tests = true
    end

    module ClassMethods
      # Метод вызывается непосредственно для объявления тестов, уже использующих транзакции.
      def uses_transaction(*methods)
        @uses_transaction = [] unless defined?(@uses_transaction)
        @uses_transaction.concat methods.map { |m| m.to_s }
      end

      def uses_transaction?(method)
        @uses_transaction = [] unless defined?(@uses_transaction)
        @uses_transaction.include?(method.to_s)
      end
    end

    # Сохранение тестовых данных в базу.
    def begin_transaction
      return if ActiveRecord::Base.configurations.blank?

      @test_connections = []

      # Load fixtures once and begin transaction.
      if run_in_transaction?
        @test_connections = enlist_test_connections
        @test_connections.each do |connection|
          connection.increment_open_transactions
          connection.transaction_joinable = false
          connection.begin_db_transaction
        end
      end
    end

    def run_in_transaction?
      use_transactional_fixtures &&
        !self.class.uses_transaction?(method_name) # method_name ссылается на имя текущего теста.
    end

    def rollback_transaction
      return if ActiveRecord::Base.configurations.blank?

      # Rollback changes if a transaction is active.
      if run_in_transaction?
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

    def enlist_test_connections
      ActiveRecord::Base.connection_handler.connection_pools.values.map(&:connection)
    end
  end
end