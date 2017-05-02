module Lastpass
  class Client

    def initialize( verbose: false )
      Lastpass.verbose = verbose
    end

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

    def logout
      return true if logged_out?
      Cli.logout
      true
    rescue
      false
    end

    def logged_in?
      Cli.status.include? 'Logged in'
    rescue
      false
    end

    def logged_out?
      !logged_in?
    end

    def accounts
      Accounts.new
    end

    def groups
      Groups.new
    end

    # Hide instance variables and values
    def inspect
      original_inspect = super
      original_inspect.split( ' ' ).first << '>'
    end
  end
end
