# Load the dogstats module.
require 'statsd'

module DatadogRails
  class Railtie < Rails::Railtie
    initializer "datadog_rails.configure_rails_initialization" do
      # Create a stats instance.
      $statsd = Statsd.new('localhost', 8125)

      # Setting up a subscriber to /process_action.action_controller/
      ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        controller = "controller:#{event.payload[:controller]}"
        action = "action:#{event.payload[:action]}"
        format = "format:#{event.payload[:format] || 'all'}"
        format = "format:all" if format == "format:*/*"
        host = "host:#{ENV['INSTRUMENTATION_HOSTNAME']}"
        status = event.payload[:status]
        tags = [controller, action, format, host]

        ActiveSupport::Notifications.instrument :performance, :action => :timing, :tags => tags, :measurement => "request.total_duration", :value => event.duration
        ActiveSupport::Notifications.instrument :performance, :action => :timing, :tags => tags, :measurement => "database.query.time", :value => event.payload[:db_runtime]
        ActiveSupport::Notifications.instrument :performance, :action => :timing, :tags => tags, :measurement => "web.view.time", :value => event.payload[:view_runtime]
        ActiveSupport::Notifications.instrument :performance, :tags => tags, :measurement => "request.status.#{status}"
      end

      # Setting up a subscriber to /performance/
      ActiveSupport::Notifications.subscribe /performance/ do |name, start, finish, id, payload|
        send_event_to_statsd(name, payload) if DatadogRails.configuration.environments.include?(Rails.env)
      end

      # Send metric to DogStatsD
      def send_event_to_statsd(name, payload)
        action = payload[:action] || :increment
        measurement = payload[:measurement]
        value = payload[:value]
        tags = payload[:tags]
        key_name = "#{name.to_s.capitalize}.#{measurement}"

        if action == :increment
          $statsd.increment key_name, :tags => tags
        else
          $statsd.histogram key_name, value, :tags => tags
        end
      end

    end
  end
end