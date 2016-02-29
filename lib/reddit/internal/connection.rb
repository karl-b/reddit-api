module Reddit
  module Internal
    class Connection

      # User Information
      attr_accessor :username
      attr_accessor :password
      attr_accessor :client_id
      attr_accessor :secret
      attr_accessor :user_agent_title

      # Token Info
      attr_accessor :token
      attr_accessor :token_expiration

      # Rate Limiting Info
      attr_accessor :request_throttle
      attr_accessor :requests_per_minute
      attr_reader :last_request_time

      # Retry Info
      attr_accessor :max_retries

      # Creates a new connection
      def initialize(username, password, client_id, secret, user_agent_title, request_throttle: nil, max_retries: nil)

        # Set up the module
        @username = username
        @password = password
        @client_id = client_id
        @secret = secret
        @user_agent_title = user_agent_title
        @token = nil

        @request_throttle = request_throttle == nil ? true : false
        @requests_per_minute = 60
        @last_request_time = Time.now.to_f

        @max_retries = max_retries ||= 3

        at_exit do
          self.sign_out()
        end
      end


      # Signs In A User, Making The Connection Active
      def sign_in()

        Reddit::Internal::Logger.log.debug "Signing In User #{@username} with client_id #{@client_id}..."
        response = JSON.parse(RestClient::Request.execute(method: :post,
                                                          url: "https://www.reddit.com/#{Reddit::Services::REFERENCE["Auth"]["access_token"]["url"]}",
                                                          payload: "grant_type=password&username=#{@username}&password=#{@password}",
                                                          user: @client_id, password: @secret))


        Reddit::Internal::Logger.log.debug "Sign In Response:"
        Reddit::Internal::Logger.log.debug JSON.pretty_generate(response)

        raise "Error Invalid Credentials" if response.include?("error")

        @token_expiration = Time.now.to_f + response["expires_in"]
        @token = response["access_token"]

        Reddit::Internal::Logger.log.info "Sign In Retrieved Token: #{@token}"
        return @token
      end


      # Signs Out A User, Killing the connection
      def sign_out()
        if @token
          Reddit::Internal::Logger.log.debug "Signing Out User #{@username} with client_id #{@client_id}..."
          response = RestClient::Request.execute(method: :post,
                                                 url: "https://www.reddit.com/#{Reddit::Services::REFERENCE["Auth"]["revoke_token"]["url"]}",
                                                 payload: "token=#{@token}",
                                                user: @client_id, password: @secret)

          Reddit::Internal::Logger.log.debug "Sign Out Response: #{response}"

          Reddit::Internal::Logger.log.info "Signed Out User #{@username}"
          @token = nil
        else

        end
      end

      # Refreshes a token (BROKEN? 400 bad request, possibly due to token still being valid...)
      def refresh()
        Reddit::Internal::Logger.log.debug "Refreshing Token For User #{@username} with client_id #{@client_id}"
        response = JSON.parse(RestClient::Request.execute(method: :post,
                                                          url: "https://www.reddit.com/#{Reddit::Services::REFERENCE["Auth"]["access_token"]["url"]}",
                                                          payload: "grant_type=refresh_token&refresh_token=#{@token}",
                                                          user: @client_id, password: @secret))

        Reddit::Internal::Logger.log.debug "Refresh Response:"
        Reddit::Internal::Logger.log.debug JSON.pretty_generate(response)

        return response
      end


      # Handles Requests From This Users Auth
      def request(method, url, payload)

        raise "User Not Signed In!" unless @token

        refresh() if @token_expiration < Time.now.to_f

        Reddit::Internal::Logger.log.debug "Reqest From User #{@username}, method: #{method}, url: #{url}"

        if @request_throttle
          Reddit::Internal::Logger.log.debug "Request Throttling Enabled, Processing Request at #{Time.now.to_f}, Last Call: #{@last_request_time}..."
          request_wait_time = @requests_per_minute / 60
          next_avaliable = @last_request_time + request_wait_time
          if Time.now.to_f < next_avaliable
            sleep_time = (next_avaliable - Time.now.to_f)
            Reddit::Internal::Logger.log.info "Rate Limiter Sleeping For #{sleep_time}"
            sleep sleep_time
          end
        end

        # Handle getting a new token if we expired...

        retries = @max_retries
        begin
          response = JSON.parse(RestClient::Request.execute(method: method, url: url, payload: payload,
                                                            headers: {"Authorization" => "bearer #{token}", "User-Agent" => "ruby-reddit-api:#{user_agent_title}"} ))
        rescue StandardError => e
          retry unless (retries -= 1).zero?
          raise e
        end
        Reddit::Internal::Logger.log.debug "Request Response:"
        Reddit::Internal::Logger.log.debug JSON.pretty_generate(response)

        @last_request_time = Time.now.to_f
        return response
      end


    end
  end
end
