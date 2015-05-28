require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'

module LogStasher
  class Railtie < Rails::Railtie
    config.logstasher = ActiveSupport::OrderedOptions.new
    config.logstasher.enabled = false
    config.logstasher.suppress_app_log = true
    config.logstasher.log_controller_parameters = true
    config.logstasher.log_level = Logger::INFO


    unless Rails.env.development? || Rails.env.test?
      config.logstasher.enabled = true
    end

    initializer :initialize_custom_logger, before: :initialize_logger, group: :all do
      app_config = Rails.application.config

      if app_config.logstasher.enabled
        app_config.logstasher.logger_path ||= ENV["LOGSTASH_LOG_PATH"] || "#{Rails.root}/log/logstash_#{Rails.env}.json"
        app_config.logstasher.logger = LogStasherRails.new(app_config.logstasher.logger_path)
        app_config.logger = app_config.logstasher.logger

        app_config.logstasher.source = "#{Rails.application.class.parent_name.downcase}_#{Rails.env}"
      end
    end

    initializer :logstasher, :before => :load_config_initializers do |app|
      if Rails.application.config.logstasher.enabled
        LogStasher.setup(app)
        LogStasher.add_custom_fields do |fields|
          fields[:parameters] = fields[:parameters].to_json
          fields[:session_id] = session["session_id"]
          fields[:environment] = Rails.env
          fields[:site] = request.path =~ /^\/api/ ? "api" : "web"

          begin
            fields.merge!(self.data_for_request_log(fields)) if self.respond_to?(:data_for_request_log)
          rescue StandardError => e
            Rails.logger.error e
          end
        end
      end
    end
  end
end
