module Lastpass
  class Collection

    def find( search_text, with_password: false )
      show( search_text, with_passwords: with_password )&.first
    end

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
