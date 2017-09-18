module Lastpass

  # Represents a collection of Lastpass objects (whether that be accounts or groups)
  #
  # @api private
  class Collection

    # Find a specific object by name or by ID
    #
    # @param search_text [String] Object name or ID
    # @param with_password [Boolean] Fetch the password along with the object details (default: false)
    # @return [Hash, NilClass]
    def find( search_text, with_password: false )
      show( search_text, with_passwords: with_password )&.first
    end

    # Find all objects by name or by ID
    #
    # @note By default, with no params specified, all objects will be returned.
    # @param search_text [String] Object name or ID (can pass in regex like '.*')
    # @param with_passwords [Boolean] Fetch the password along with the object details (default: false)
    # @return [Array<Hash>]
    def find_all( search_text = '.*', with_passwords: false )
      show( search_text, with_passwords: with_passwords, regex: true ) || []
    end

    private

    def show( search_text, regex: false, with_passwords: false )
      begin
        response = Cli.show( search_text, expand_multi: true, all: true, basic_regexp: regex )
      rescue => e
        if e.message.include? 'Could not find specified account'
          return nil # Just means nothing was found
        else
          raise e # Something is wrong, re-raise the exception
        end
      end
      Parser.parse( response, with_passwords: with_passwords )
    end
  end
end
