require_relative '../../../test_helper.rb'

require_package 'graph/functions'

require_relative '../sentiment.rb'

describe Process::Sentiment do
  let(:instance) { Process::Sentiment.new }
  let(:f) { Graph::Functions }

  describe '#fetch' do
    before do
      Graph::Sentiment.create(name: 'Test', latitude: 46.9479, longitude: 7.4446)
    end

    it 'renders found nodes' do
      result = instance.fetch(latitude: 46.9479, longitude: 7.4446)

      assert_equals f.many_json(Graph::Sentiment.all), result
    end
  end
end
