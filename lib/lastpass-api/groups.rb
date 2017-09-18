module Lastpass

  # Interact with Lastpass groups/folders
  class Groups < Collection

    # Find a specific group by name or by ID
    #
    # @param search_text [String] Group name or ID
    # @param with_password [Boolean] Fetch the account passwords along with the group details (default: false)
    # @return [Lastpass::Group, NilClass]
    # @example
    #   # Find a specific group by name
    #   group = @lastpass.groups.find( 'Group1' )
    #
    #   # Find a specific group by ID
    #   group = @lastpass.groups.find( '1234' )
    def find( search_text, with_password: false )
      search_text.to_s.gsub!( '/', '' )
      search_text << '/' unless is_number?( search_text )
      params = super
      if params.is_a?( Hash ) && params[:name]&.end_with?( '/' )
        Group.new( params )
      end
    end

    # Find all groups by name or by ID
    #
    # @note By default, with no params specified, all groups will be returned.
    # @param search_text [String] Group name or ID (can pass in regex like '.*')
    # @param with_passwords [Boolean] Fetch the account passwords along with the group details (default: false)
    # @return [Array<Lastpass::Group>]
    # @example
    #   # Find all groups that match string (or regex)
    #   groups = @lastpass.groups.find_all( 'Gro' )
    #   puts groups.count
    #   puts groups.first.to_h
    #
    #   # Fetch all groups - same as find_all( '.*' )
    #   @lastpass.groups.find_all
    def find_all( search_text = '.*', with_passwords: false )
      groups = super.select { |params| params[:name]&.end_with? '/' }
      groups.map do |params|
        Group.new( params )
      end
    end

    # Create a new group
    #
    # @param params [Hash]
    # @return [Lastpass::Group]
    # @example
    #   group = @lastpass.groups.create( name: 'Group1' )
    #   puts group.id
    def create( params )
      params.delete( :id ) # Prevent overwriting ID
      Group.new( params ).save
    end

    # Hide instance variables and values
    #
    # @api private
    def inspect
      original_inspect = super
      original_inspect.split( ' ' ).first << '>'
    end

    private

    def is_number?( string )
      true if Float(string) rescue false
    end
  end
end
