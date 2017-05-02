require 'lastpass-api/utils'
require 'lastpass-api/collection'
require 'lastpass-api/cli'
require 'lastpass-api/client'
require 'lastpass-api/account'
require 'lastpass-api/accounts'
require 'lastpass-api/group'
require 'lastpass-api/groups'
require 'lastpass-api/parser'

# Read/Write API client for LastPass using the LastPass CLI. I am not
# affiliated with LastPass.
#
# @author {mailto:eterry1388@aol.com Eric Terry}
# @note Tested with LastPass CLI v1.1.2
# @note This gem currently can only login with one account at a time!
module Lastpass
  @@verbose = false

  def self.verbose
    @@verbose
  end

  def self.verbose=( verbose )
    @@verbose = verbose
  end

  def self.check_lpass_in_path
    error_message = 'Cannot find the "lpass" executable in the path!'
    begin
      raise error_message if Utils.cmd( 'which lpass' ) == ''
    rescue
      raise error_message
    end
    version = Utils.cmd( 'lpass --version' )
    unless version.include? 'v1.'
      raise "The LastPass CLI you have installed [#{version&.chomp}] is not supported. Please install LastPass CLI v1"
    end
  end

  check_lpass_in_path # Check upon requiring the gem
end
