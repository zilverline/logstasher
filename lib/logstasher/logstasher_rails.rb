class LogStasherRails < Logger

  def format_message(severity, timestamp, progname, message)
    event = {
      "@timestamp" => timestamp,
      "@version" => "1",
      "tags" => ["log"],
      "message" => message.to_s,
      "severity" => severity,
      "environment" => Rails.env,
      "source" => LogStasher.source
    }

    begin
      if message.is_a?(Exception)
        event["message"] = message.message
        event["tags"] << "exception"
        event["trace"] = message.backtrace.join("\n") if message.backtrace
      end
    rescue
    end

    "#{LogStasher.scrub(event.to_json)}\n"
  end

  def <<(msg)
    super(LogStasher.scrub(msg.to_s))
  end
end
