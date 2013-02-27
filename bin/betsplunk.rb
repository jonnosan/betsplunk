#!/opt/local/bin/ruby1.9 -rubygems

require 'logger'
require 'trollop'
require_relative '../lib/betsplunk'

logger = Logger.new(STDOUT)
logger.level = Logger::WARN


SUB_COMMANDS= %w{status install}
opts = Trollop::options do
    banner "betsplunk management utility"
    opt :rcfile, ".rc file", :default=>"~/.splunkrc"                    # flag --monkey, default false
    opt :debug, "print debug info to stdout", :default=>false
    opt :host, "splunk server hostname", :default=>'localhost'
    opt :port, "splunk server management port", :default=>8089
    opt :username, "splunk username", :default=>'admin'
    opt :password, "splunk password", :default=>'changeme'
    opt :scheme, "scheme", :default=> 'https'
    opt :version,"server API version", :default => '5.0'

    stop_on SUB_COMMANDS
  end

      
full_rc_file_path=File.expand_path(opts[:rcfile])
if File.readable?(full_rc_file_path)
    logger.debug("reading #{full_rc_file_path}")
    file = File.new(full_rc_file_path)
  
    file.readlines.each do |raw_line|
        line = raw_line.strip()
        if line.start_with?("\#") or line.length == 0
            next
        else
        raw_key, raw_value = line.split('=', limit=2)
        key = raw_key.strip().intern
        next if raw_value.nil?            
        value = raw_value.strip()
        if opts["#{key}_given".to_sym]
            logger.debug("skipping #{raw_key} setting, using command line version")  
        else 
        
            logger.debug("setting #{raw_key} to #{raw_value}")  
            if key == 'port'
                value = Integer(value)
            end
            opts[key] = value
        end
    end
  end
elsif opts[:rcfile_given]
    puts "WARNING: could not read rc file #{opts[:rcfile]}"
else
    
   logger.debug("skipping #{full_rc_file_path}")  
end

logger.level = Logger::DEBUG if opts[:debug]

if opts[:debug]
    p opts 
end

cmd = ARGV.shift # get the subcommand
betsplunk=BetSplunk.new(opts,logger)
Trollop::die "missing subcommand" if cmd.nil?

if (betsplunk.respond_to?(cmd))
    begin
        betsplunk.send(cmd)
    rescue Exception => e  
        puts e.message  
        puts e.backtrace if opts[:debug]
    end  
else
    Trollop::die "unknown subcommand #{cmd}"
end