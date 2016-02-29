module Reddit
  module Services
    # Everything else in the services module is created at runtime through the "service.rb" generator

    class User

      attr_accessor :name
      attr_accessor :token

      attr_accessor :connection

      def initialize(username, password, client_id, secret, user_agent_title, options = {})

        raise "user_agent_title must be set, please follow the reddit API rules" if user_agent_title == nil

        @name = username
        @connection = Reddit::Internal::Connection.new(username, password, client_id, secret, user_agent_title, options)
        @connection.sign_in()
        @token = @connection.token
      end
    end
  end
end
