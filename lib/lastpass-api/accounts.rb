module Lastpass

  # Interact with Lastpass accounts
  class Accounts < Collection

    # Find a specific account by name or by ID
    #
    # @param search_text [String] Account name or ID
    # @param with_password [Boolean] Fetch the password along with the account details (default: false)
    # @return [Lastpass::Account, NilClass]
    # @example
    #   # Find a specific account by name
    #   account = @lastpass.accounts.find( 'MyAccount', with_password: true )
    #
    #   # Find a specific account by ID
    #   account = @lastpass.accounts.find( 1234, with_password: true )
    def find( search_text, with_password: false )
      params = super
      if params.is_a?( Hash ) && !params[:name]&.end_with?( '/' )
        Account.new( params )
      end
    end

    # Find all accounts by name or by ID
    #
    # @note By default, with no params specified, all accounts will be returned.
    # @param search_text [String] Account name or ID (can pass in regex like '.*')
    # @param with_passwords [Boolean] Fetch the password along with the account details (default: false)
    # @return [Array<Lastpass::Account>]
    # @example
    #   # Find all accounts that match string (or regex)
    #   accounts = @lastpass.accounts.find_all( 'MyAcc' )
    #   puts accounts.count
    #   puts accounts.first.to_h
    #
    #   # Fetch all accounts - same as find_all( '.*' )
    #   @lastpass.accounts.find_all
    def find_all( search_text = '.*', with_passwords: false )
      accounts = super.select { |params| !params[:name]&.end_with? '/' }
      accounts.map do |params|
        Account.new( params )
      end
    end

    # Create a new account
    #
    # @param params [Hash]
    # @return [Lastpass::Account]
    # @example
    #   # Create an optional group to place account into
    #   @lastpass.groups.create( name: 'MyGroup' )
    #
    #   # Create account
    #   account = @lastpass.accounts.create(
    #     name: 'MyAccount',
    #     username: 'root',
    #     password: 'pass',
    #     url: 'http://www.example.com',
    #     notes: 'This is my note.',
    #     group: 'MyGroup'
    #   )
    #   puts account.id
    def create( params )
      params.delete( :id ) # Prevent overwriting ID
      Account.new( params ).save
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
