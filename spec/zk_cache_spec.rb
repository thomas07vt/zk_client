require 'spec_helper'

describe ZkCache do
  before do
    ZkCache.destroy_cache
  end

  context '.cache and .read' do
    it 'caches the item passed and is readable' do
      ZkCache.cache('/test_key', 'test value')
      expect(ZkCache.read('/test_key')).to eq('test value')
    end
  end

  context '.load_cache' do
    before do
      @keys = [
        "/rspec",
        "/rspec/first",
        "/rspec/second",
        "/rspec/second/innner"
      ]
      @keys.each { |key| ZkClient.write(key, 'value!') }
      ZkClient.root_path = '/rspec'
    end

    after do
      @keys.each { |key| ZkClient.delete(key) }
      ZkClient.root_path = '/'
    end

    it 'loads all data from zk' do
      cache = JSON.parse(ZkCache.load_cache)
      expect(@keys - cache.keys).to eq([])
    end
  end

  context 'destroy_cache' do
    before do
      @key = 'my-test-key'
      ZkCache.cache(@key, 'value.')
    end

    it 'deletes all items from cache' do
      ZkCache.destroy_cache
      expect(ZkCache.read(@key)).to eq(nil)
    end
  end

end

