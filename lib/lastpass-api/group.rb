module Lastpass

  # Interact with a Lastpass group/folder
  class Group
    attr_reader :id
    attr_accessor :name

    # @param params [Hash]
    def initialize( params )
      params[:name].chomp!( '/' ) if params[:name]&.end_with? '/'
      params_to_group( params )
    end

    # Update the group details
    #
    # @param params [Hash]
    # @example
    #   group = @lastpass.groups.find( 'Group1' )
    #   group.update( name: 'Group1 EDIT' )
    def update( params )
      deleted! if @deleted
      params.delete( :id ) # Prevent overwriting ID
      params_to_group( params )
      save
    end

    # Either create or update a group, depending on what
    # was changed on the group object before this method was called.
    #
    # @example
    #   # Update using instance variables
    #   group = @lastpass.groups.find( 'Group1' )
    #   group.name = 'Group1 EDIT'
    #   group.save
    def save
      deleted! if @deleted
      # If there is an ID, update that entry
      if @id
        Cli.edit_group( @id, name: @name )
      else # If no ID, that means this is a new entry
        Cli.add_group( @name )
        set_id_after_save
      end
      self
    end

    # Delete the group
    #
    # @example
    #   group = @lastpass.groups.find( 1234 )
    #   group.delete
    def delete
      Cli.rm( @id )
      @deleted = true
    end

    # Hash representation of the account object
    #
    # @return [Hash]
    # @example
    #   puts group.to_h
    #   # => { id: '1234', name: 'Group1' }
    def to_hash
      params = {}
      params[:id]   = @id   if @id
      params[:name] = @name if @name
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

    def params_to_group( params )
      @id   = params[:id]   if params[:id]
      @name = params[:name] if params[:name]
    end

    def set_id_after_save
      response = Cli.show( "#{@name}/", id: true )
      if response.nil? || response == '' || response.include?( 'Multiple matches found' )
        raise "Unable to fetch ID of newly created group! Name may have not been unique. Response: #{response}"
      end
      @id = response
    end

    def deleted!
      raise "Group [ID:#{@id}] has been deleted!"
    end
  end
end
