module Lastpass

  # Interact with a Lastpass account
  class Account
    attr_reader :id
    # @todo Make group editable eventually
    attr_reader :group
    attr_accessor :name, :username, :password, :url, :notes

    # @param params [Hash]
    def initialize( params )
      params_to_account( params )
    end

    # Update the account details
    #
    # @param params [Hash]
    # @example
    #   account = @lastpass.accounts.find( 'MyAccount' )
    #   account.update(
    #     name: 'MyAccount EDIT',
    #     username: 'root EDIT',
    #     password: 'pass EDIT',
    #     url: 'http://www.exampleEDIT.com',
    #     notes: 'This is my note. EDIT'
    #   )
    def update( params )
      deleted! if @deleted
      params.delete( :id ) # Prevent overwriting ID
      params.delete( :group ) # Prevent overwriting group
      params_to_account( params )
      save
    end

    # Either create or update an account, depending on what
    # was changed on the account object before this method was called.
    #
    # @todo This does not support changing groups yet!
    # @example
    #   # Update using instance variables
    #   account = @lastpass.accounts.find( 'MyAccount' )
    #   account.name = 'MyAccount EDIT'
    #   account.username = 'root EDIT'
    #   account.password = 'pass EDIT'
    #   account.url = 'http://www.exampleEDIT.com'
    #   account.notes = 'This is my notes. EDIT'
    #   account.save
    def save
      deleted! if @deleted
      # If there is an ID, update that entry
      if @id
        Cli.edit( @id,
          name:     @name,
          username: @username,
          password: @password,
          url:      @url,
          notes:    @notes,
          group:    @group
        )
      else # If no ID, that means this is a new entry
        Cli.add( @name,
          username: @username,
          password: @password,
          url:      @url,
          notes:    @notes,
          group:    @group
        )
        set_id_after_save
      end
      self
    end

    # Delete the account
    #
    # @example
    #   account = @lastpass.accounts.find( 1234 )
    #   account.delete
    def delete
      Cli.rm( @id )
      @deleted = true
    end

    # Hash representation of the account object
    #
    # @return [Hash]
    # @example
    #   puts account.to_h
    #   # => { id: '1234', name: 'MyAccount', username: 'root', password: 'pass', url: 'http://www.example.com', notes: 'This is my note.', group: 'MyGroup' }
    def to_hash
      params = {}
      params[:id]       = @id       if @id
      params[:name]     = @name     if @name
      params[:username] = @username if @username
      params[:password] = @password if @password
      params[:url]      = @url      if @url
      params[:notes]    = @notes    if @notes
      params[:group]    = @group    if @group
      params
    end

    alias_method :to_h, :to_hash

    # Hide instance variables and values
    #
    # @api private
    def inspect
      original_inspect = super
      original_inspect.split( ' ' ).first << '>'
    end

    private

    def params_to_account( params )
      set_group_and_name( params[:name] ) # Infer group from the name
      @group    = params[:group]    if params[:group] # Overwrite group if explicitly set
      @id       = params[:id]       if params[:id]
      @username = params[:username] if params[:username]
      @password = params[:password] if params[:password]
      @url      = params[:url]      if params[:url]
      @notes    = params[:notes]    if params[:notes]
    end

    def set_group_and_name( string )
      if string
        split_name = string.split( '/' )
        if split_name.count == 1
          @name = split_name.first
        else
          @name = split_name.last
          @group = split_name.first
        end
      end
    end

    def set_id_after_save
      show_name = ''
      show_name << "#{@group}/" if @group
      show_name << @name
      response = Cli.show( show_name, id: true )
      if response.nil? || response == '' || response.include?( 'Multiple matches found' )
        raise "Unable to fetch ID of newly created account! Name may have not been unique. Response: #{response}"
      end
      @id = response
    end

    def deleted!
      raise "Account [ID:#{@id}] has been deleted!"
    end
  end
end
