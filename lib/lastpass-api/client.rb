module Lastpass

  # Main class to interact with Lastpass API
  class Client

    # @param verbose [Boolean] Set if you want to turn on verbose mode.  Turning on
    #   verbose will show much more output. This is good for debugging.  It will
    #   output any commands that are executed with "lpass". (default: false)
    # @example Without verbose
    #   require 'lastpass-api'
    #   @lastpass = Lastpass::Client.new
    # @example With verbose mode on
    #   require 'lastpass-api'
    #   @lastpass = Lastpass::Client.new( verbose: true )
    def initialize( verbose: false )
      Lastpass.verbose = verbose
    end

    # Login to Lastpass
    #
    # @note This is not thread safe. Only one login session can be active at a time.
    # @note If there is a valid active login session already when this is called, it
    #   will use that session rather than create a new one.
    # @param email [String] Lastpass master email
    # @param password [String] Lastpass master password
    # @raise [RuntimeError] if login failed
    # @return [Boolean] if login was successful
    # @example
    #   @lastpass.login( email: 'user@example.com', password: 'secret' )
    #   puts @lastpass.logged_in?
    def login( email:, password: )
      if logged_in?
        Cli.sync
        return true
      end
      response = Cli.login( email, password: password )
      raise "Login failed! #{response}" unless response.include? 'Success'
      Cli.sync
      @password = nil # Clear out password
      true
    end

    # Logout of Lastpass
    #
    # @return [Boolean] if logout was successful
    # @example
    #   @lastpass.logout
    #   puts @lastpass.logged_out?
    def logout
      return true if logged_out?
      Cli.logout
      true
    rescue
      false
    end

    # Check to see if currently logged into Lastpass
    #
    # @return [Boolean]
    def logged_in?
      Cli.status.include? 'Logged in'
    rescue
      false
    end

    # Check to see if logged out of Lastpass
    #
    # @return [Boolean]
    def logged_out?
      !logged_in?
    end

    # Interface to interacting with Lastpass accounts
    #
    # @return [Lastpass::Accounts]
    def accounts
      Accounts.new
    end

    # Interface to interacting with Lastpass groups
    #
    # @return [Lastpass::Groups]
    def groups
      Groups.new
    end

    # Hide instance variables and values
    #
    # @api private
    def inspect
      original_inspect = super
      original_inspect.split( ' ' ).first << '>'
    end
  end
end
