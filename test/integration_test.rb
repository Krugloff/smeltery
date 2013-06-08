require_relative 'needs'

class IntegrationTest < LibraryTest
  test 'first' do
    _create_ingots
    _save_models
    _delete_users
    _delete_articles
    _save_articles
  end

  private

    def _create_ingots
      _set_count
      @articles =
        Smeltery::Storage.find_or_create "#{__dir__}/ingots/articles.rb"

      assert_equal @before_article, Article.connection.records
      assert @before_user < User.connection.records
      assert_equal Smeltery::Storage.cache.size, 2
    end

    def _save_models
      _set_count and Smeltery::Furnace.models @articles

      assert @before_article < Article.connection.records
      assert_equal @before_user, User.connection.records
    end

    def _delete_users
      _set_count
      @users = Smeltery::Storage.find_or_create "#{__dir__}/ingots/users.rb"
      Smeltery::Furnace.ingots @users

      assert_equal @before_article, Article.connection.records
      assert @before_user > User.connection.records
    end

    def _delete_articles
      _set_count and Smeltery::Furnace.ingots @articles

      assert @before_article > Article.connection.records
      assert_equal @before_user, User.connection.records
    end

    def _save_articles
      _set_count and Smeltery::Furnace.models @articles

      assert @before_article < Article.connection.records
      assert @before_user < User.connection.records
    end

    def _set_count
      @before_article = Article.connection.records
      @before_user = User.connection.records
    end
end