require 'timeout'

module Lastpass

  # Low-level interaction with LastPass CLI
  #
  # @api private
  # @example
  #   Lastpass::Cli.login( username, password:, trust: false, plaintext_key: false, force: false )
  #   Lastpass::Cli.logout( force: false )
  #   Lastpass::Cli.show( account, clip: false, expand_multi: false, all: false, basic_regexp: false, id: false )
  #   Lastpass::Cli.ls( group = nil, long: false, m: false, u: false )
  #   Lastpass::Cli.add( name, username: nil, password: nil, url: nil, notes: nil, group: nil )
  #   Lastpass::Cli.add_group( name )
  #   Lastpass::Cli.edit( id, name: nil, username: nil, password: nil, url: nil, notes: nil, group: nil )
  #   Lastpass::Cli.edit_group( id, name: )
  #   Lastpass::Cli.rm( id )
  #   Lastpass::Cli.status( quiet: false )
  #   Lastpass::Cli.sync
  #   Lastpass::Cli.export
  #   Lastpass::Cli.import( csv_filename )
  #   Lastpass::Cli.version
  class Cli
    # @todo Make this configurable? Or at least smarter?
    UPLOAD_QUEUE_PATH = '~/.lpass/upload-queue'

    # Login to LastPass, opening up a global session
    #
    # @note lpass login [--trust] [--plaintext-key [--force, -f]] [--color=auto|never|always] USERNAME
    def self.login( username, password:, trust: false, plaintext_key: false, force: false )
      command = "echo '#{password}' | LPASS_DISABLE_PINENTRY=1 lpass login"
      command << ' --trust' if trust
      command << ' --plaintext-key' if plaintext_key
      command << ' --force' if force
      command << " '#{escape( username )}'"
      Utils.cmd command
    end

    # @note lpass logout [--force, -f] [--color=auto|never|always]
    def self.logout( force: false )
      command = 'echo "Y" | lpass logout'
      command << ' --force' if force
      Utils.cmd command
    end

    # @note lpass passwd
    # @todo Not yet implemented
    def self.passwd
      not_implemented!
    end

    # @note lpass show [--sync=auto|now|no] [--clip, -c] [--expand-multi, -x] [--all|--username|--password|--url|--notes|--field=FIELD|--id|--name|--attach=ATTACHID] [--basic-regexp, -G|--fixed-strings, -F] [--color=auto|never|always] \\{UNIQUENAME|UNIQUEID}
    def self.show( account, clip: false, expand_multi: false, all: false, basic_regexp: false, id: false )
      sync # Ensure everything is synced up before running!
      command = 'lpass show'
      command << ' --clip' if clip
      command << ' --expand-multi' if expand_multi
      command << ' --all' if all
      command << ' --basic-regexp' if basic_regexp
      command << ' --id' if id
      command << " '#{escape( account )}'"
      response = Utils.cmd command
      # Don't let LastPass know the accounts were accessed as it clogs up the sync!
      # So clear out sync files if a lot of accounts were accessed at the same time.
      remove_sync_files if response.length > 400
      response
    end

    # @note lpass ls [--sync=auto|now|no] [--long, -l] [-m] [-u] [--color=auto|never|always] [GROUP]
    def self.ls( group = nil, long: false, m: false, u: false )
      sync # Ensure everything is synced up before running!
      command = 'lpass ls'
      command << ' --long' if long
      command << ' -m' if m
      command << ' -u' if u
      command << " '#{escape( group )}'" if group
      response = Utils.cmd command
      # Don't let LastPass know the accounts were accessed as it clogs up the sync!
      # So clear out sync files if a lot of accounts were accessed at the same time.
      remove_sync_files if response.length > 400
      response
    end

    # @note lpass mv [--color=auto|never|always] \\{UNIQUENAME|UNIQUEID} GROUP
    # @todo Not yet implemented
    def self.mv
      not_implemented!
    end

    # @note lpass add [--sync=auto|now|no] [--non-interactive] [--color=auto|never|always] \\{--username|--password|--url|--notes|--field=FIELD|--note-type=NOTETYPE} NAME
    def self.add( name, username: nil, password: nil, url: nil, notes: nil, group: nil )
      data = {}
      data[:Username] = escape( username,   double: true ) if username
      data[:Password] = escape( password,   double: true ) if password
      data[:URL]      = escape( url,        double: true ) if url
      data[:Notes] = '\n' << escape( notes, double: true ) if notes

      command = 'printf "'
      command << data.map { |d| d.join( ': ' ) }.join( '\n' )
      command << '" | lpass add --non-interactive --sync=no \''
      command << "#{escape( group )}/" if group
      command << "#{escape( name )}'"
      response = Utils.cmd command
      sync
      response
    end

    # @note lpass add [--sync=auto|now|no] [--non-interactive] [--color=auto|never|always] \\{--username|--password|--url|--notes|--field=FIELD|--note-type=NOTETYPE} NAME
    def self.add_group( name )
      response = Utils.cmd "printf 'URL: http://group' | lpass add --non-interactive --sync=no '#{escape( name )}/'"
      sync
      response
    end

    # @note lpass edit [--sync=auto|now|no] [--non-interactive] [--color=auto|never|always] \\{--name|--username|--password|--url|--notes|--field=FIELD} \\{NAME|UNIQUEID}
    def self.edit( id, name: nil, username: nil, password: nil, url: nil, notes: nil, group: nil )
      data = {}
      name_with_group = ''
      name_with_group << "#{group}/" if group
      name_with_group << name if name

      data[:Name]     = escape( name_with_group, double: true ) unless name_with_group == ''
      data[:Username] = escape( username,        double: true ) if username
      data[:Password] = escape( password,        double: true ) if password
      data[:URL]      = escape( url,             double: true ) if url
      data[:Notes] = '\n' << escape( notes,      double: true ) if notes

      command = 'printf "'
      command << data.map { |d| d.join( ': ' ) }.join( '\n' )
      command << '" | lpass edit --non-interactive --sync=no '
      command << id
      response = Utils.cmd command
      sync
      response
    end

    # @note lpass edit [--sync=auto|now|no] [--non-interactive] [--color=auto|never|always] \\{--name|--username|--password|--url|--notes|--field=FIELD} \\{NAME|UNIQUEID}
    # @note This does actually rename the project even though it looks like it
    #   creates a new group in Lastpass. This is because the original creds that
    #   were under this project have the group name in the name of the creds
    #   (yay for Lastpass awesomeness). So, after a project rename, newly created
    #   creds will go under the new group name.  Old creds will rename in the
    #   old pseudo name.
    def self.edit_group( id, name: )
      command = 'printf "'
      command << "Name: #{escape( name, double: true )}/"
      command << '" | lpass edit --non-interactive --sync=no '
      command << id
      response = Utils.cmd command
      sync
      response
    end

    # @note lpass generate [--sync=auto|now|no] [--clip, -c] [--username=USERNAME] [--url=URL] [--no-symbols] \\{NAME|UNIQUEID} LENGTH
    # @todo Not yet implemented
    def self.generate
      not_implemented!
    end

    # @note lpass duplicate [--sync=auto|now|no] [--color=auto|never|always] \\{UNIQUENAME|UNIQUEID}
    # @todo Not yet implemented
    def self.duplicate
      not_implemented!
    end

    # @note lpass rm [--sync=auto|now|no] [--color=auto|never|always] \\{UNIQUENAME|UNIQUEID}
    def self.rm( id )
      response = Utils.cmd "lpass rm --sync=no #{id}"
      sync
      response
    end

    # @note lpass status [--quiet, -q] [--color=auto|never|always]
    def self.status( quiet: false )
      command = 'lpass status'
      command << ' --quiet' if quiet
      Utils.cmd command
    end

    # @note This is a buggy function of the lpass executable. May not be super reliable.
    # @note lpass sync [--background, -b] [--color=auto|never|always]
    def self.sync
      sleep 1 # Allow file IO before attempting sync
      Utils.cmd 'lpass sync'
      sleep 1 # Allow sync to finish
    end

    # @note lpass export [--sync=auto|now|no] [--color=auto|never|always]
    def self.export
      Utils.cmd 'lpass export'
    end

    # @note lpass import [CSV_FILENAME]
    def self.import( csv_filename )
      Utils.cmd "lpass import '#{escape( csv_filename )}'"
    end

    # @note lpass share subcommand sharename ...
    # @todo Not yet implemented
    def self.share
      not_implemented!
    end

    # @note lpass --version
    def self.version
      Utils.cmd 'lpass --version'
    end

    private

    # For methods that are not yet implemented
    #
    # @raise Command not implemented
    def self.not_implemented!
      raise 'Command not implemented!'
    end

    # Escapes single or double quotes in strings
    #
    # @param string [String] the string to escape
    # @param double [Boolean] whether to escape double quotes (defaults to single quotes)
    # @return [String] escaped string
    def self.escape( string, double: false )
      if double
        string.to_s.gsub( '"', '\"' )
      else # Assume single quotes
        string.to_s.gsub( "'", "\\\\'" )
      end
    end

    # Remove sync files, which can get stuck because of lpass bug
    def self.remove_sync_files
      puts 'Removing sync files!'.red if Lastpass.verbose
      sleep 5 # Hopefully any prior syncs will finish before clearning out stuck ones
      Utils.cmd "rm -f #{UPLOAD_QUEUE_PATH}/*"
    end
  end
end
