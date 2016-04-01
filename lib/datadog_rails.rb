require "datadog_rails/configuration"

require 'datadog_rails/railtie' if defined?(Rails::Railtie)

module DatadogRails
  class << self
    attr_writer :configuration
    attr_writer :client

    # Embed in a String to clear all previous ANSI sequences.
    CLEAR   = "\e[0m"
    BOLD    = "\e[1m"

    # Colors
    BLACK   = "\e[30m"
    RED     = "\e[31m"
    GREEN   = "\e[32m"
    YELLOW  = "\e[33m"
    BLUE    = "\e[34m"
    MAGENTA = "\e[35m"
    CYAN    = "\e[36m"
    WHITE   = "\e[37m"

    def configuration
      @configuration ||= DatadogRails::Configuration.new
    end

    def configure
      yield(configuration)

      self.client = nil
    end

    def client
      @client ||= Statsd.new configuration.dogstatsd_host, configuration.dogstatsd_port
    end

    def send_event_to_statsd(payload)
      key_name = "#{configuration.application_name}.#{payload[:measurement]}"

      if payload[:action] == :increment
        client.increment key_name, :tags => payload[:tags]
      else
        client.histogram key_name, payload[:value], :tags => payload[:tags]
      end

      log_event(payload) if configuration.debug?
    end

    def log_event(payload)
      key_name = "#{configuration.application_name}.#{payload[:measurement]}"

      info = "\n"
      info << " \tmethod => #{payload[:action]}\n"
      info << " \tmetric => #{key_name}\n"
      info << " \tvalue  => #{payload[:value]}\n"
      info << " \ttags   => #{payload[:tags]}"

      Rails.logger.info color(" DatadogRails", GREEN, true) + color(info, WHITE, true)
    end

    def color(text, color, bold=false)
      bold  = bold ? BOLD : ""
      "#{bold}#{color}#{text}#{CLEAR}"
    end
  end
end