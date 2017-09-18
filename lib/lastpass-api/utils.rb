require 'colorize'
require 'open3'

module Lastpass

  # Internal utility class
  #
  # @api private
  class Utils

    # Run a command
    #
    # @param command [String]
    # @param output [Boolean] Print command output on stdout (default: false)
    # @raise [StandardError] if execution of command has errors
    # @return [String] Command output
    def self.cmd( command, output: false )
      puts "RUN COMMAND:  #{command}".green if Lastpass.verbose
      @stdout = ''
      Open3::popen3( command ) do |stdin, stdout, stderr, wait_thr|
        stdout.sync = true
        while line = stdout.gets
          puts line if Lastpass.verbose || output
          @stdout << line
        end

        exit_status = wait_thr.value
        unless exit_status.success?
          puts "COMMAND:  #{command}".red if Lastpass.verbose
          stderr_text = stderr.read
          puts stderr_text.red if Lastpass.verbose
          raise StandardError, "Command: '#{command}', Stdout: '#{stdout.read}', Stderr: '#{stderr_text}'"
        end
      end

      return @stdout
    rescue Errno::ENOENT => e
      puts "COMMAND:  #{command}".red if Lastpass.verbose
      puts "#{e}".red if Lastpass.verbose
      raise StandardError, "Command: '#{command}', Error: '#{e}'"
    end
  end
end
