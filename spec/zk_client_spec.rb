require 'spec_helper'
require 'pry'

describe ZkClient do
  it 'has a version number' do
    expect(ZkClient::VERSION).not_to be nil
  end

  context '.read' do
    it 'returns the nodes data' do
      expect(ZkClient.read("/zk_client")).to eq("rspec")
    end

    it 'appends leading slash on the key if needed' do
      expect(ZkClient.read("zk_client")).to eq("rspec")
    end
  end

  context '#read_node' do
    it 'returns the whole node hash' do
      expect(ZkClient.read_node("/zk_client").class).to eq(Hash)
    end

    it 'exposes a data key' do
      expect(ZkClient.read_node("/zk_client")[:data]).to eq("rspec")
    end

    it 'exposes the stat key' do
      expect(ZkClient.read_node("/zk_client")[:stat]).to_not eq(nil)
    end
  end

  context '.write' do
    after do
      ZkClient.write('/zk_client', 'rspec')
    end

    describe 'when the path exists' do
      it 'writes data to the existing zk key' do
        ZkClient.write('/zk_client', 'test-val')
        expect(ZkClient.read('/zk_client')).to eq('test-val')
      end
    end

    describe 'when the path does not exist' do
      after do
        ZkClient.delete('/zk_client_new')
      end

      it 'creates the key then writes data to the new zk key' do
        resp = ZkClient.write('/zk_client_new', 'test-val')
        expect(ZkClient.read('/zk_client_new')).to eq('test-val')
      end
    end

  end

  context '.delete' do
    before do
      ZkClient.create('/zk_client_del', 'delete me')
    end

    after do
      expect(ZkClient.read_node('/zk_client_del')[:stat].exists).to eq(false)
    end

    it 'deletes the node' do
      rsp = ZkClient.delete('/zk_client_del')
      expect(ZkClient.read_node('/zk_client_del')[:stat].exists).to eq(false)
    end

  end

  context '.client' do
    it 'returns the zk client' do
      expect(ZkClient.client.class).to eq(Zookeeper::Client)
    end
  end

  context '.close' do
    before do
      expect(ZkClient.client.connected?).to eq(true)
    end

    after do
      ZkClient.reopen
    end

    it 'closes the client connection' do
      ZkClient.close
      expect(ZkClient.client.connected?).to eq(false)
    end
  end

  context '.host' do
    before do
      ZkClient.host = 'localhost'
    end

    it 'allows the setting of the host' do
      ZkClient.host = 'test.example.com'
      expect(ZkClient.host).to eq('test.example.com')
    end

    it 'returns the host' do
      expect(ZkClient.host).to eq('localhost')
    end
  end

  context '.port' do
    before do
      ZkClient.port = '2181'
    end

    it 'allows the setting of the port' do
      ZkClient.port = '9999'
      expect(ZkClient.port).to eq(9999)
    end

    it 'returns the port' do
      expect(ZkClient.port).to eq(2181)
    end
  end

  #context '.scheme' do
  #  before do
  #    ZkClient.scheme = 'http'
  #  end

  #  it 'allows the setting of the scheme' do
  #    ZkClient.scheme = 'https'
  #    expect(ZkClient.scheme).to eq('https')
  #  end

  #  it 'returns the scheme' do
  #    expect(ZkClient.scheme).to eq('http')
  #  end
  #end

  context '.root_path' do
    before do
      ZkClient.root_path = '/'
    end

    it 'allows the setting of the root_path' do
      ZkClient.root_path = '/zk_root_path'
      expect(ZkClient.root_path).to eq('/zk_root_path')
    end

    it 'returns the root_path' do
      expect(ZkClient.root_path).to eq('/')
    end
  end

  context '.uri' do
    before do
      ZkClient.uri = 'localhost:2181'
    end

    it 'allows the setting of the uri' do
      ZkClient.uri = 'http://test.example.com:2111/zk_client'
      expect(ZkClient.uri).to eq('test.example.com:2111')
    end

    it 'returns the uri' do
      expect(ZkClient.uri).to eq('localhost:2181')
    end

    #it 'sets the scheme' do
    #  ZkClient.uri = 'https://test.example.com:2111/zk_client'
    #  expect(ZkClient.scheme).to eq('https')
    #end

    it 'sets the host' do
      ZkClient.uri = 'https://test.example.com:2111/zk_client'
      expect(ZkClient.host).to eq('test.example.com')
    end

    it 'sets the root_path' do
      ZkClient.uri = 'https://test.example.com:2111/zk_client'
      expect(ZkClient.root_path).to eq('/zk_client')
    end


    it 'sets the port' do
      ZkClient.uri = 'https://test.example.com:2111/zk_client'
      expect(ZkClient.port).to eq(2111)
    end

  end

  context '.config' do
    after do
      ZkClient.root_path = '/zk_client'
    end

    it 'exposes the uri method' do
      ZkClient.config do |zk|
        zk.uri = 'https://test.example.com:4444/hmm?test=ok'
      end

      expect(ZkClient.host).to eq('test.example.com')
      expect(ZkClient.port).to eq(4444)
      expect(ZkClient.root_path).to eq('/hmm')
    end

    it 'exposes config methods' do
      ZkClient.config do |zk|
        zk.host = 'test.myexample.com'
        zk.port = 9999
        zk.root_path = '/rspec'
      end

      expect(ZkClient.host).to eq('test.myexample.com')
      expect(ZkClient.port).to eq(9999)
      expect(ZkClient.root_path).to eq('/rspec')
    end

  end

  context '.children' do
    describe 'when the node does not exist' do
      before do
        expect(ZkClient.read_node("/doesntexist")[:stat].exists).to eq(false)
      end

      it 'returns nil' do
        expect(ZkClient.children('/doesntexist')).to eq(nil)
      end

    end

    describe 'when the node exists but has no children' do
      before do
        ZkClient.write("/no_children", "data")
        expect(ZkClient.read_node("/no_children")[:stat].numChildren).to eq(0)
      end

      it 'returns an empy array' do
        expect(ZkClient.children('/no_children')).to eq([])
      end

    end

    describe 'when the node has children' do
      before do
        puts "HERE: #{ZkClient.read_node("/")}"
        puts "#{ZkClient.root_path}"
        expect(ZkClient.read_node("/")[:stat].numChildren).to eq(1)
      end

      it 'returns nil' do
        expect(ZkClient.children('/')).to eq(["no_children"])
      end

    end
  end

  context '.reopen' do
    before do
      ZkClient.host = 'localhost'
      ZkClient.port = 2181
      ZkClient.close
      expect(ZkClient.client.connected?).to eq(false)
    end

    it 'connects a closed Zookeeper.new() client' do
      ZkClient.reopen
      expect(ZkClient.client.connected?).to eq(true)
    end
  end


end
