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

  # Verbose mode flag
  def self.verbose
    @@verbose
  end

  # Set if you want to turn on verbose mode.  Turning on verbose will show much more output.
  # This is good for debugging.  It will output any commands that are executed with "lpass".
  #
  # @return [Boolean]
  # @example
  #   Lastpass.verbose = true
  def self.verbose=( verbose )
    @@verbose = verbose
  end

  private

  # Make sure "lpass" is installed with the correct version.
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
