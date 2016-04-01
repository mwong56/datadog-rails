# Load the dogstats module.
require 'statsd'

module DatadogRails
  class Railtie < Rails::Railtie
    config.datadog_rails = ActiveSupport::OrderedOptions.new

    initializer "datadog_rails.configure" do |app|
      DatadogRails.configure do |config|
        config.application_name             = app.config.datadog_rails[:application_name] || ::Rails.application.class.parent_name.underscore
        config.dogstatsd_host               = app.config.datadog_rails[:dogstatsd_host] || config.dogstatsd_host
        config.dogstatsd_port               = app.config.datadog_rails[:dogstatsd_port] || config.dogstatsd_port
        config.instrumentation_environments = app.config.datadog_rails[:instrumentation_environments] || config.instrumentation_environments
        config.instrumentation_enabled      = app.config.datadog_rails[:instrumentation_enabled] || config.instrumentation_enabled
        config.debug                        = app.config.datadog_rails[:debug] || config.debug
      end
    end

    initializer "datadog_rails.configure_rails_initialization" do |app|
      # Setting up a subscriber to /process_action.action_controller/
      ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)

        controller = "controller:#{event.payload[:controller]}"
        action     = "action:#{event.payload[:action]}"
        format     = "format:#{event.payload[:format] || 'all'}"
        format     = "format:all" if format == "format:*/*"
        status     = "status:#{event.payload[:status]}"

        tags = [controller, action, format, status]

        ActiveSupport::Notifications.instrument :performance, :action => :increment, :tags => tags, :measurement => "request.number",           :value => 1
        ActiveSupport::Notifications.instrument :performance, :action => :histogram, :tags => tags, :measurement => "request.total_duration",   :value => event.duration
        ActiveSupport::Notifications.instrument :performance, :action => :histogram, :tags => tags, :measurement => "database.query.time",      :value => event.payload[:db_runtime]
        ActiveSupport::Notifications.instrument :performance, :action => :histogram, :tags => tags, :measurement => "web.view.time",            :value => event.payload[:view_runtime]
      end

      # Setting up a subscriber to /performance/
      ActiveSupport::Notifications.subscribe /performance/ do |name, start, finish, id, payload|
        if DatadogRails.configuration.instrumentation_enabled? and
           DatadogRails.configuration.instrumentation_environments.include?(Rails.env)
          DatadogRails.send_event_to_statsd(payload)
        elsif DatadogRails.configuration.instrumentation_enabled?
          DatadogRails.log_event(payload)
        end
      end
    end
  end
end
