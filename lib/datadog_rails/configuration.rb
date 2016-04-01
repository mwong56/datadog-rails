module DatadogRails
  class Configuration
    attr_accessor :application_name
    attr_accessor :dogstatsd_host
    attr_accessor :dogstatsd_port
    attr_accessor :instrumentation_environments
    attr_accessor :instrumentation_enabled
    attr_accessor :debug

    DEFAULTS = {
      :dogstatsd_host => "localhost",
      :dogstatsd_port => 8125,
      :instrumentation_environments => ["production"],
      :instrumentation_enabled => true,
      :debug => false
    }

    def initialize
      @dogstatsd_host = DEFAULTS[:dogstatsd_host]
      @dogstatsd_port = DEFAULTS[:dogstatsd_port]
      @instrumentation_environments = DEFAULTS[:instrumentation_environments]
      @instrumentation_enabled = DEFAULTS[:instrumentation_enabled]
      @debug = DEFAULTS[:debug]
    end

    def debug?
      !!@debug
    end

    def instrumentation_enabled?
      !!@instrumentation_enabled
    end
  end
end