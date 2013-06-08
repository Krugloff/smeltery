require_relative '../needs'

class ModelTest < LibraryTest

  setup do
    @ingot = Smeltery::Storage::Ingot.new :admin, name: 'Krugloff'
    @model = Smeltery::Furnace::Model.new TestModel, @ingot
  end

  test 'cool' do
    before = records_count
    _cool

    assert records_count > before
  end

  test 'cool invalid' do
    before = records_count
    @model.instance_variable_get('@model').invalid = true
    _cool

    assert_equal records_count, before
  end

  test 'to ingot' do
    assert !@ingot.respond_to?(:to_model)

    @model.cool
    before = records_count
    ingot = @model.to_ingot

    assert records_count < before
    assert @ingot.respond_to? :to_model
    assert_equal ingot.class, Smeltery::Storage::Ingot
  end

  private

    def records_count
       TestModel.connection.records
    end

    def _cool
      model = @model.cool

      assert_equal model.class, TestModel
      assert_equal TestModel.last, model
      assert model.attributes.has_key? :name
    end
end