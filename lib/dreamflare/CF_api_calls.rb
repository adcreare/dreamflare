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

        def update_record(name,type,value, priority=nil)

            uri  = URI("https://api.cloudflare.com/client/v4/zones/af53c6784ad906452f9b8ed589fd805b/dns_records")
            #puts uri

            https = Net::HTTP.new(uri.host,uri.port)
            https.use_ssl = true

            req = Net::HTTP::Post.new(uri.path)
            req['Content-Type'] = 'application/json'
            req['X-Auth-Key'] = @@APIKey
            req['X-Auth-Email'] = @@APIEmail

            if(priority)
                req.body = {"type" => type,"name" => name,"content" => value, 'priority' => priority}.to_json
            else
                req.body = {"type" => type,"name" => name,"content" => value}.to_json
            end


            res = https.request(req)
            responseObject = JSON.parse(res.body)


            if(responseObject["success"])
                puts("successfully created record   -   "+name+"    "+type+"    "+value)
            else
                puts("------------------------")
                puts("failed to create record  -   "+name+"    "+type+"    "+value)
                puts(responseObject)
                puts("------------------------")
            end


            # curl -X POST "https://api.cloudflare.com/client/v4/zones/af53c6784ad906452f9b8ed589fd805b/dns_records" \
            #      -H "X-Auth-Email: david@commscentral.net" \
            #      -H "X-Auth-Key: ab6b55cbc084891a75f90d8f1a6a2afa04a3b" \
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


            responseObject = process_response(JSON.parse(res.body))

            return responseObject

        end

        private

        def process_response(cfResults)

          matchingCFZones = []

          if cfResults['success'] == true
            cfResults['result'].each do |dnsRecord|
                h = {'record' => dnsRecord['name'],'value' => dnsRecord['content'],'type' =>dnsRecord['type']}

                if(!dnsRecord['priority'].nil?)
                  #puts('priority is SET!')

                  h['priority'] = dnsRecord['priority']
                end
                # h['priority'] =

                matchingCFZones.push(h)
            end
          end

          return matchingCFZones
        end

    end #end CFAPIQuery class

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
