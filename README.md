Datadog Rails
=============

Send Rails application metrics to DogStatsD

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'datadog_rails'
```

And then execute.

```shell
$ bundle
```

Or install it yourself as:

```shell
gem install datadog_rails
```

## Usage

Add the configuration to an initializer:

```ruby
DatadogRails.configure do |config|
  config.application_name             = "my_custom_app"               # default: Rails app name
  config.dogstatsd_host               = "localhost"                   # default: "localhost"
  config.dogstatsd_port               = 8125                          # default: 8125
  config.instrumentation_environments = ["development", "production"] # default: ["production"]
  config.instrumentation_enabled      = true                          # default: true
  config.debug                        = true                          # default: false
end
```

## Metrics

| Metric                           |
| -------------------------------- |
| app_name.request.number          |
| app_name.request.total_duration  |
| app_name.database.query.time     | 
| app_name.web.view.time           | 

## License

Copyright 2016 Mesa Inc. MIT License.
