#betsplunk management library
require 'splunk-sdk-ruby'
class BetSplunk
  def initialize(opts,logger)
    @opts=opts
  end
  
  def service
    @service ||= Splunk::connect(@opts)
  end
  def status
    service.apps.each do |app|
      #p app
    end
  end

  def install
  end
  
end