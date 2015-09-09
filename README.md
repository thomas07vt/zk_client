# ZkClient

A simple Zookeeper client used in the Mojo framework. This gem allows quick and simple access to a Zookeeper server.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zk_client', :git => 'https://git.autodesk.com/EIS-EA-MOJO/zk_client.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zk_client --source http://10.40.83.93 # This is a local gem server

## Usage

#### How to configure your Zookeeper client

By default ZkClient uses 'localhost:2181' as the Zookeeper server, and '/' as the root_path. More on that later. But if you want to point to a different zk server, or change the root_path, then you will have to 'configure' the Zookeeper Client.

There are a few ways to configure the Zookeeper client (ZkClient).

##### Using the config block and allowing ZkClient to parse a uri

```ruby
require 'zk_client'

ZkClient.config do |zk|
  zk.uri = 'my-zk-server.com:8000/application/path'
end

ZkClient.host
#=> "my-zk-server.com"
ZkClient.port
#=> 8000
ZkClient.root_path
#=> "/application/path"
ZkClient.uri
#=> "my-zk-server.com:8000"

```

##### Using the config block and directly setting zk variables

```ruby
require 'zk_client'

ZkClient.config do |zk|
  zk.host = 'test.myexample.com'
  zk.port = 9999
  zk.root_path = '/new/application/path'
end

ZkClient.host
#=> "test.myexample.com"
ZkClient.port
#=> 9999
ZkClient.root_path
#=> "/new/application/path"
ZkClient.uri
#=> "test.myexample.com:9999"

```

##### Using the ZkClient directly and setting zk variables

```ruby
require 'zk_client'

ZkClient.host = 'test.myexample.com'
ZkClient.port = 9999
ZkClient.root_path = '/new/application/path'

ZkClient.host
#=> "test.myexample.com"
ZkClient.port
#=> 9999
ZkClient.root_path
#=> "/new/application/path"
ZkClient.uri
#=> "test.myexample.com:9999"

```


#### Interacting with a Zookeeper Server

##### Reading data from an existing node

```ruby
require 'zk_client'

# Assuming you have a node at the path '/mynode' with the data value of 'my data!'
ZkClient.read('/mynode')
#=> "my data!"

```

##### Reading data from node that doesn't exist

```ruby
require 'zk_client'

ZkClient.read('/doesntexist')
#=> nil

```

##### Sometimes you want to return the whole node with stats too

```ruby
require 'zk_client'

ZkClient.read_node('/mynode')
#=> {:req_id=>3, :rc=>0, :data=>"my data!", :stat=>#<Zookeeper::Stat:0x000000028569f0 @exists=true, @czxid=2, @mzxid=10665, @ctime=1425596120895, @mtime=1441087085411, @version=2, @cversion=3, @aversion=0, @ephemeralOwner=0, @dataLength=0, @numChildren=3, @pzxid=9621>}

```

##### Writing data

```ruby
require 'zk_client'

ZkClient.write('/mynode', "This is my data")
#=> {:req_id=>5, :rc=>0, :path=>"/mynode"} 
ZkClient.read('/mynode')
#=> "This is my data"
```

##### Deleting a node

```ruby
require 'zk_client'

ZkClient.delete('/mynode')
#=> {:req_id=>7, :rc=>0} 
ZkClient.read_node('/mynode')
#=> {:req_id=>9, :rc=>-101, :data=>nil, :stat=>#<Zookeeper::Stat:0x00000002803f70 @exists=false>}
```

##### Close connection to ZK

```ruby
require 'zk_client'

ZkClient.client.connected?
#=> true 
ZkClient.close
#=> nil
ZkClient.client.connected?
#=> false 

```

##### Access the underlying Zookeeper.new instance
```ruby
require 'zk_client'

# Sometimes you might want to interact with the Zookeeper::Client directly.
# To do that just call .client:
raw_client = ZkClient.client
#=> #<Zookeeper::Client:0x0000000280da70 @host="localhost:2181", @chroot_path="", 0x0000000280c198 @level=0,
# ...
# ...
raw_client.class
#=> Zookeeper::Client 

```


## Contributing

1. Fork it ( https://git.autodesk.com/EIS-EA-MOJO/zk_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
