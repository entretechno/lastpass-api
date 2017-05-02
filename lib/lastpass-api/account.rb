module Lastpass
  class Account
    attr_reader :id, :group # TODO: Make group editable eventually
    attr_accessor :name, :username, :password, :url, :notes

    def initialize( params )
      params_to_account( params )
    end

    def update( params )
      deleted! if @deleted
      params.delete( :id ) # Prevent overwriting ID
      params.delete( :group ) # Prevent overwriting group
      params_to_account( params )
      save
    end

    # TODO: This does not support changing groups yet!
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

    def delete
      Cli.rm( @id )
      @deleted = true
    end

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
