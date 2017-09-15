module Lastpass
  class Groups < Collection

    def find( search_text, with_password: false )
      search_text.to_s.gsub!( '/', '' )
      search_text << '/' unless is_number?( search_text )
      params = super
      if params.is_a?( Hash ) && params[:name]&.end_with?( '/' )
        Group.new( params )
      end
    end

    def find_all( search_text = '.*', with_passwords: false )
      groups = super.select { |params| params[:name]&.end_with? '/' }
      groups.map do |params|
        Group.new( params )
      end
    end

    def create( params )
      params.delete( :id ) # Prevent overwriting ID
      Group.new( params ).save
    end

    # Hide instance variables and values
    def inspect
      original_inspect = super
      original_inspect.split( ' ' ).first << '>'
    end
  end

  private

  def is_number?( string )
    true if Float(string) rescue false
  end
end
