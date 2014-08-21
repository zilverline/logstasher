# Logstasher for Zilverline Rails projects

## Installing

Add the following line to the Gemfile:

```
gem "logstasher", git: "git@github.com:zilverline/logstasher.git"
```

Logstasher will now be enabled in all environments except development and test.

### Ansible

Make sure the `logstash` role is enabled in your project's ansible playbook.

## Override configuration

When you want to enable logstasher in another environment change the corrosponding environment file:

```
# in config/environments/RAILS_ENV.rb
config.logstasher.enabled = true
```

The following configuration keys are available:

```
# path to write the log to, defaults to ENV["LOGSTASH_LOG_PATH"] or #{Rails.root}/log/logstash_#{Rails.env}.json.
config.logstasher.logger_path

# log level, defaults to Logger::INFO
config.logstasher.log_level
```

## Add custom data to request

Override the following method in any controller where you want to add extra data to the request. Or in the
application controller if you want it for every request.

```
# fields are already processed, you can overwrite or remove keys if you need to.
# the Hash you return will be merged with fields.
def data_for_request_log(fields)
  {
    test: "foobar"
  }
end
```

## File uploads

Since all parameters are converted to json before they are written to the log file, it is important that you
filter all binary parameters from the log.

```
# in config/initializers/filter_parameter_logging.rb

Rails.application.config.filter_parameters += [:password, :access_token, :attachments]
```

You'll get a `Encoding::UndefinedConversionError` when you forget to filter binary parameters.
