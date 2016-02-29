module Reddit
  module Internal
    module Processor
      extend self

      attr_accessor :base_url
      @base_url = "https://oauth.reddit.com/"


      def process(module_name, function_name, user, payload, var_hash)
        ref_data = Reddit::Services::REFERENCE[module_name][function_name.split("_").drop(1).join("/")]


        # URL Building
        if ref_data["fields"].include?("basepath_subreddit")
          raise "Basepath Subreddit Required But Not Passed!" unless var_hash[:basepath_subreddit]
          # Subreddit Exception (As its not listed in the json file)
          url = "#{@base_url}r/#{var_hash[:basepath_subreddit]}/#{ref_data["url"]}"
        else
          url = "#{@base_url}#{ref_data["url"]}"
        end


        # Url Basepath
        var_hash.each do |k,v|
          if k.to_s.include?("basepath_") && !k.to_s.include?("basepath_subreddit")
            url.gsub!(k.to_s.split("_").drop(1).join("_"), v)
          end
        end

        # Url Params
        url += "?" + var_hash.collect { |k,v| "#{k.to_s}=#{v.to_s}" unless k.to_s.include?("basepath_") }.join("&") if var_hash.length > var_hash.select{|k,v| k.to_s.include?("basepath_")}.length


        # Make the request via the user
        user.connection.request(ref_data["method"], url, payload)
      end


      def batch_call(module_name, function_name, user, var_hash)
        #Setup Local Vars
        page_size = var_hash[:page_size]
        max_size = var_hash[:max_size]
        remove_sticky = var_hash[:remove_sticky]

        remove_sticky = true if remove_sticky == nil

        raise "page_size parameter missing!" unless page_size
        raise "max_size parameter missing!" unless max_size
        raise "page_size cannot be zero!" if page_size == 0

        # Delete Paging Specific Hash Set
        var_hash.delete(:page_size)
        var_hash.delete(:max_size)
        var_hash.delete(:remove_sticky)

        # Set up our out of loop variables
        total_results = []
        last_entry = nil

        # Process Requests
        Reddit::Internal::Logger.log.debug "Processing Batch #{module_name} -> #{function_name}:"
        (max_size / page_size).times do |index|
          Reddit::Internal::Logger.log.debug "Batch [#{index} / #{(max_size / page_size)}]"
          # Setup Vars For Local Batch
          page_var_hash = var_hash ? var_hash : {}
          page_var_hash["after"] = last_entry if last_entry
          page_var_hash["count"] = index * page_size
          page_var_hash["limit"] = page_size

          # Fetch Batch
          result_batch = Reddit::Internal::Processor.process(module_name, function_name, user, nil, page_var_hash)
          result_batch = result_batch["data"]["children"]

          # Remove Extra Sticky Posts
          result_batch = result_batch.drop(result_batch.length - page_size) unless last_entry if remove_sticky

          # Merge Results
          total_results += result_batch

          # Check if break / setup for next set.
          break if result_batch.length < page_size
          last_entry = result_batch.last["data"]["name"]
        end
        return total_results
      end

    end
  end
end
