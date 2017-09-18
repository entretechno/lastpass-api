module Lastpass

  # Internal class for parsing through Lastpass raw output
  #
  # @api private
  class Parser

    # Method to interact directly with parser
    #
    # @param raw_string [String] Lastpass CLI response string
    # @param with_passwords [Boolean] Whether or not to return passwords
    # @return [Array<Hash>]
    def self.parse( raw_string, with_passwords: false )
      new( raw_string, with_passwords: with_passwords ).parse_all
    end

    # @param (see parse)
    def initialize( raw_string, with_passwords: false )
      @raw_string = raw_string
      @with_passwords = with_passwords
      @all = {}
    end

    # Parse through all lines in raw output
    #
    # @return [Array<Hash>]
    def parse_all
      @raw_string.split( "\n" ).each do |line|
        parse_line( line )
      end
      @all.values
    end

    # Hide instance variables and values
    #
    # @api private
    def inspect
      original_inspect = super
      original_inspect.split( ' ' ).first << '>'
    end

    private

    def parse_line( line )
      parent_match = line.match( /^(.+)\s\[id:\s(\d+)\]$/ )
      child_match = line.match( /^((?!\s\[id:\s)[\s\S])*$/ )
      if parent_match
        parent_id = parent_match[2]
        parent_name = parent_match[1]
        @all[parent_id] = { id: parent_id, name: parent_name }
        @parent_id = parent_id
      elsif child_match
        child_parsed_match = child_match[0].match( /^(\w+):\s(.*)$/ )
        if child_parsed_match && @parent_id
          key = child_parsed_match[1]
          value = child_parsed_match[2]
          @all[@parent_id] ||= {}
          return if !@with_passwords && key.downcase.to_sym == :password
          @all[@parent_id][key.downcase.to_sym] = value
        end
      end
    end
  end
end
