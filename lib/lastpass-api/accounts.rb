module Lastpass
  class Accounts < Collection

    def find( search_text, with_password: false )
      params = super
      if params.is_a?( Hash ) && !params[:name]&.end_with?( '/' )
        Account.new( params )
      end
    end

    def find_all( search_text = '.*', with_passwords: false )
      accounts = super.select { |params| !params[:name]&.end_with? '/' }
      accounts.map do |params|
        Account.new( params )
      end
    end

    def create( params )
      params.delete( :id ) # Prevent overwriting ID
      Account.new( params ).save
    end

    # Hide instance variables and values
    def inspect
      original_inspect = super
      original_inspect.split( ' ' ).first << '>'
    end
  end
end
