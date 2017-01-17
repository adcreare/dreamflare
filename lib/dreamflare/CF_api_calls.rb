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

        def update_record(name,type,value)

            uri  = URI("https://api.cloudflare.com/client/v4/zones/af53c6784ad906452f9b8ed589fd805b/dns_records")
            puts uri

            https = Net::HTTP.new(uri.host,uri.port)
            https.use_ssl = true

            req = Net::HTTP::Post.new(uri.path)
            req.add_field('Content-Type', 'application/json')
            req['X-Auth-Key'] = @@APIKey
            req['X-Auth-Email'] = @@APIEmail
            req["body"] = {'type' => type,'name' => name,'content' => value}.to_json

            puts req["body"]



            res = https.request(req)

            puts(JSON.parse(res.body))

            throw "DONE"

            # curl -X POST "https://api.cloudflare.com/client/v4/zones/023e105f4ecef8ad9ca31a8372d0c353/dns_records" \
            #      -H "X-Auth-Email: user@example.com" \
            #      -H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41" \
            #      -H "Content-Type: application/json" \
            #      --data '{"type":"A","name":"example.com","content":"127.0.0.1","ttl":120,"proxied":false}'

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
