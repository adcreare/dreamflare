module Dreamflare

    class DHAPIQuery
        @@APIKey = '' #private variable

        def initialize(apiKey)
            @@APIKey = apiKey
        end

        def uuid
            SecureRandom.uuid
        end


        def query(command, params = '')

            uri  = URI("https://api.dreamhost.com/?key=#{@@APIKey}&cmd=#{command}&unique_id=#{uuid}&format=json#{params unless params.empty?}")
            puts uri
            connection = Net::HTTP.new(uri.host, uri.port)
            connection.use_ssl = true
            data = connection.get(uri.request_uri)

            return JSON.parse(data.body)

        end

    end

    ##################
    #
    # FUNCTION
    # Input: TODO
    # Return: json responsed
    # Purpose: run commands against dream host api
    #
    ##################
    def dh_api_query(command, params = '')

    end

end
