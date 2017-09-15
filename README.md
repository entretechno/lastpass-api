# Lastpass API

[![Gem Version](https://badge.fury.io/rb/lastpass-api.svg)](https://badge.fury.io/rb/lastpass-api)
![](http://ruby-gem-downloads-badge.herokuapp.com/lastpass-api?type=total)
[![Inline docs](http://inch-ci.org/github/entretechno/lastpass-api.svg?branch=master)](http://inch-ci.org/github/entretechno/lastpass-api)

Read/Write access to the online [LastPass](https://www.lastpass.com) vault using LastPass CLI to create, read, and update account information and credentials.

## Installation

```bash
gem install lastpass-api
```

This gem depends on [lpass](https://github.com/lastpass/lastpass-cli), which requires the `lpass` executable to be installed and in the PATH. Try running one of these (depending on your OS) to install `lpass`:

```bash
# Ubuntu (may have to build manually to install verion v1)
sudo apt-get install openssl libcurl4-openssl-dev libxml2 libssl-dev libxml2-dev pinentry-curses xclip cmake
sudo apt-get install lastpass-cli

# Homebrew (OS X)
brew update && brew install lastpass-cli

# MacPorts (OS X)
sudo port selfupdate && sudo port install lastpass-cli

# Debian (may have to build manually to install verion v1)
sudo apt-get install openssl libcurl3 libxml2 libssl-dev libxml2-dev libcurl4-openssl-dev pinentry-curses xclip
sudo apt-get install lastpass-cli

# Fedora
sudo dnf install lastpass-cli

# Redhat/Centos
sudo yum install openssl libcurl libxml2 pinentry xclip openssl-devel libxml2-devel libcurl-devel
sudo yum install lastpass-cli

# Gentoo
sudo emerge lastpass-cli

# FreeBSD
sudo pkg install security/lastpass-cli
sudo make -C /usr/ports/security/lastpass-cli all install clean

# Cygwin
apt-cyg install wget make cmake gcc-core gcc-g++ openssl-devel libcurl-devel libxml2-devel libiconv-devel cygutils-extra
```

### Instructions for building manually

```bash
git clone https://github.com/lastpass/lastpass-cli.git
cd lastpass-cli
git checkout v1.1.2 # Or whatever version you'd like
cmake . && make
sudo make install
# Reload path or login to a new shell terminal
lpass --version
# or
./lpass --version
```

Further instructions can be found here:  https://github.com/lastpass/lastpass-cli#building

## Usage

```ruby
require 'lastpass-api'
@lastpass = Lastpass::Client.new
```

### Login

```ruby
@lastpass.login( email: 'user@example.com', password: 'secret' )
puts @lastpass.logged_in?
```

### Accounts

#### Create account credentials

```ruby
# Create an optional group to place account into
@lastpass.groups.create( name: 'MyGroup' )

# Create account
account = @lastpass.accounts.create(
  name: 'MyAccount',
  username: 'root',
  password: 'pass',
  url: 'http://www.example.com',
  notes: 'This is my note.',
  group: 'MyGroup'
)
puts account.id
```

#### Find and read credentials

```ruby
# Find a specific account by name
account = @lastpass.accounts.find( 'MyAccount', with_password: true )

# Find a specific account by ID
account = @lastpass.accounts.find( 1234, with_password: true )

puts account.to_h
# => { id: '1234', name: 'MyAccount', username: 'root', password: 'pass', url: 'http://www.example.com', notes: 'This is my note.', group: 'MyGroup' }

# Find all accounts that match string (or regex)
accounts = @lastpass.accounts.find_all( 'MyAcc' )
puts accounts.count
puts accounts.first.to_h

# Fetch all accounts - same as find_all( '.*' )
@lastpass.accounts.find_all
```

#### Update account

```ruby
# Update using instance variables
account = @lastpass.accounts.find( 'MyAccount' )
account.name = 'MyAccount EDIT'
account.username = 'root EDIT'
account.password = 'pass EDIT'
account.url = 'http://www.exampleEDIT.com'
account.notes = 'This is my notes. EDIT'
account.save

# Update using the update method
account = @lastpass.accounts.find( 'MyAccount' )
account.update(
  name: 'MyAccount EDIT',
  username: 'root EDIT',
  password: 'pass EDIT',
  url: 'http://www.exampleEDIT.com',
  notes: 'This is my note. EDIT'
)
```

#### Delete account

```ruby
account = @lastpass.accounts.find( 1234 )
account.delete
```

### Groups (Folders)

#### Create group

```ruby
group = @lastpass.groups.create( name: 'Group1' )
puts group.id
```

#### Find group

```ruby
# Find a specific group by name
group = @lastpass.groups.find( 'Group1' )

# Find a specific group by ID
group = @lastpass.groups.find( '1234' )

puts group.to_h
# => { id: '1234', name: 'Group1' }

# Find all groups that match string (or regex)
groups = @lastpass.groups.find_all( 'Gro' )
puts groups.count
puts groups.first.to_h

# Fetch all groups - same as find_all( '.*' )
@lastpass.groups.find_all
```

#### Update group (rename a group)

```ruby
# Update using instance variables
group = @lastpass.groups.find( 'Group1' )
group.name = 'Group1 EDIT'
group.save

# Update using the update method
group = @lastpass.groups.find( 'Group1' )
group.update( name: 'Group1 EDIT' )
```

#### Delete group

```ruby
group = @lastpass.groups.find( 1234 )
group.delete
```

### Logout

```ruby
@lastpass.logout
puts @lastpass.logged_out?
```

### Verbose

Turning on verbose will show much more output.  This is good for debugging.  It will output any commands that are executed with `lpass`.

```ruby
@lastpass = Lastpass::Client.new( verbose: true )
# or
Lastpass.verbose = true
```

### Directly interacting with CLI

```ruby
Lastpass::Cli.login( username, password:, trust: false, plaintext_key: false, force: false )
Lastpass::Cli.logout( force: false )
Lastpass::Cli.show( account, clip: false, expand_multi: false, all: false, basic_regexp: false, id: false )
Lastpass::Cli.ls( group = nil, long: false, m: false, u: false )
Lastpass::Cli.add( name, username: nil, password: nil, url: nil, notes: nil, group: nil )
Lastpass::Cli.add_group( name )
Lastpass::Cli.edit( id, name: nil, username: nil, password: nil, url: nil, notes: nil, group: nil )
Lastpass::Cli.edit_group( id, name: )
Lastpass::Cli.rm( id )
Lastpass::Cli.status( quiet: false )
Lastpass::Cli.sync
Lastpass::Cli.export
Lastpass::Cli.import( csv_filename )
Lastpass::Cli.version
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/entretechno/lastpass-api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
