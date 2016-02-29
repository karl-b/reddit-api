module Reddit
  module Internal
    module Logger
      extend self

      attr_accessor :log
      attr_accessor :enable_file_logging
      @enable_file_logging = false

      @log = Log4r::Logger.new("reddit_api.log")
      @log.outputters << Log4r::FileOutputter.new("reddit_api.log", filename: "reddit_api.log") if @enable_file_logging
      @log.outputters << Log4r::Outputter.stdout

      @log.level = Log4r::WARN 
    end
  end
end
