module Reddit
  module Services
    extend self
    Reddit::Internal::Logger.log.debug "Loading REFERENCE."
    REFERENCE = JSON.parse(File.read(File.expand_path("../../../data/reddit_api.json", __FILE__)))
    Reddit::Internal::Logger.log.debug "REFERENCE Loaded."

    private
    # Generates a given function
    def generate_function(new_module, module_name, hash)
      # Generate our Get and Post Functions
      method_name = "#{hash["method"]}_#{hash["name"].split("/").join("_")}"

      Reddit::Internal::Logger.log.debug "Generating Funcgion #{module_name}.#{method_name}"

      if hash["method"] == "post"
        new_module.define_singleton_method(method_name) do |user, payload, options = {}|
          Reddit::Internal::Processor.process(module_name, method_name, user, payload, options)
        end
      else
        new_module.define_singleton_method(method_name) do |user, options = {}|
          Reddit::Internal::Processor.process(module_name, method_name, user, nil, options)
        end
      end

      #Generate Print Function
      print_name = "print_#{method_name}"
      new_module.define_singleton_method(print_name) do
        Reddit::Internal::Logger.debug "Fields: #{REFERENCE[module_name][hash["name"]]["fields"]}"
        REFERENCE[module_name][hash["name"]]["fields"]
      end

      # Generate the batch functions on GET endpoints for listings (As other endpoints tend to output different data formats)
      if hash["method"] == "get" && module_name == :Listings
        batch_name = "batch_#{hash["name"].split("/").join("_")}"
        new_module.define_singleton_method(batch_name) do |user, options = {}|
          Reddit::Internal::Processor.batch_call(module_name, method_name, user, options)
        end
      end
    end

    # Itterate through the given JSON and generate modules and functions
    REFERENCE.each do |api_module, module_functions|
      Reddit::Internal::Logger.log.debug "Generating Module: #{api_module}"
      new_module = Module.new do
        module_functions.each do |name, function_hash|
          Reddit::Services.send(:generate_function, self, api_module, function_hash)
        end
      end
      Reddit::Services.const_set(api_module, new_module)
      Reddit::Internal::Logger.log.debug "Generating Module: #{api_module} Completed."
    end
  end
end
