module Dreamflare

    class CFAPIQuery
        @@APIKey = '' #private variable usied by all instances of the class (hence @@)
        @@APIEmail = ''

        def initialize(apiKey,apiEmail)
            @@APIKey = apiKey
            @@APIEmail = apiEmail
        end

        def uuid
            SecureRandom.uuid
        end


        def query(zone,command, params = '')

            uri  = URI("https://api.cloudflare.com/client/v4/zones/#{zone}/#{command}")
            puts uri

            https = Net::HTTP.new(uri.host,uri.port)
            https.use_ssl = true

            req = Net::HTTP::Get.new(uri.path)
            req.add_field('Content-Type', 'application/json')
            req['X-Auth-Key'] = @@APIKey
            req['X-Auth-Email'] = @@APIEmail

            res = https.request(req)
            puts


            #data = res

            return JSON.parse(res.body)

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
