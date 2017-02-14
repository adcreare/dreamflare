module Dreamflare
    class CFAPIQuery
        @@APIKey = '' # private variable usied by all instances of the class (hence @@)
        @@APIEmail = ''
        @CFResponseObject = {}

        def initialize(apiKey, apiEmail)
            @@APIKey = apiKey
            @@APIEmail = apiEmail
        end

        def uuid
            SecureRandom.uuid
        end

        def create_record(name, type, value, priority = nil)
            uri = URI('https://api.cloudflare.com/client/v4/zones/af53c6784ad906452f9b8ed589fd805b/dns_records')
            # puts uri

            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true

            req = Net::HTTP::Post.new(uri.path)
            req['Content-Type'] = 'application/json'
            req['X-Auth-Key'] = @@APIKey
            req['X-Auth-Email'] = @@APIEmail

            if priority
                req.body = { 'type' => type, 'name' => name, 'content' => value, 'priority' => priority }.to_json
            else
                req.body = { 'type' => type, 'name' => name, 'content' => value }.to_json
            end

            res = https.request(req)
            responseObject = JSON.parse(res.body)

            if responseObject['success']
                puts('successfully created record   -   ' + name + '    ' + type + '    ' + value)
            else
                #  puts("------------------------")
                puts('failed to create record  -   ' + name + '    ' + type + '    ' + value)
                puts(responseObject)
                #  puts("------------------------")
            end

            # curl -X POST "https://api.cloudflare.com/client/v4/zones/af53c6784ad906452f9b8ed589fd805b/dns_records" \
            #      -H "X-Auth-Email: david@commscentral.net" \
            #      -H "X-Auth-Key: ab6b55cbc084891a75f90d8f1a6a2afa04a3b" \
            #      -H "Content-Type: application/json" \
            #      --data '{"type":"A","name":"example.com","content":"127.0.0.1","ttl":120,"proxied":false}'
        end

        def query(zone, command, _params = '')
            make_http_request(zone, command)
        end

        def update_record(record)
            puts 'Update record CF:'
            puts record

            # 1. Lookup record and get ID
            recordID = get_cf_record_id(record)

            # 2. call the update function
            make_http_request_update_put(recordID, record)


        end

        #####################################################################
        #####################################################################
        private

        def make_http_request_update_put(dnsrecordID, recordValue)

            #curl -X PUT "https://api.cloudflare.com/client/v4/zones/023e105f4ecef8ad9ca31a8372d0c353/dns_records/372e67954025e0ba6aaa6d586b9e0b59" \
            # -H "X-Auth-Email: user@example.com" \
            # -H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41" \
            # -H "Content-Type: application/json" \
            # --data '{"type":"A","name":"example.com","content":"127.0.0.1","ttl":120,"proxied":false}'

            uri = URI('https://api.cloudflare.com/client/v4/zones/af53c6784ad906452f9b8ed589fd805b/dns_records/' + dnsrecordID)
            # puts uri

            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true

            req = Net::HTTP::Put.new(uri.path)
            req['Content-Type'] = 'application/json'
            req['X-Auth-Key'] = @@APIKey
            req['X-Auth-Email'] = @@APIEmail

            req.body = recordValue.to_json

            res = https.request(req)
            responseObject = JSON.parse(res.body)


        end

        # something to do the query
        # page starting at 1 because page 1 and no page number == in CloudFlare
        def make_http_request(zone, command, pageValue = 1)
            page = ''
            page = '&page=' + String(pageValue) if pageValue > 1

            uri = URI("https://api.cloudflare.com/client/v4/zones/#{zone}/#{command}#{page}")
            puts 'Calling cloudflare api: ' + String(uri)

            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true

            req = Net::HTTP::Get.new(uri.path)
            req.add_field('Content-Type', 'application/json')
            req['X-Auth-Key'] = @@APIKey
            req['X-Auth-Email'] = @@APIEmail

            res = https.request(req)

            # get http response
            reponseFromQuery = JSON.parse(res.body)

            # get page info from api
            intPage = reponseFromQuery['result_info']['page']
            intTotalPages = reponseFromQuery['result_info']['total_pages']

            # process the response into the format we want
            reponseFromQuery = process_response(reponseFromQuery)

            if intPage < intTotalPages # if we have more pages to go make a recursive call

                # add the reponse obtained to the result of the next call that contains the next page (bump the page number too)
                return(reponseFromQuery + make_http_request(zone, command, (pageValue + 1)))

            else
                return reponseFromQuery # must be the last page, just return the reponse
            end
        end

        def process_response(cfResults)
            # puts cfResults
            matchingCFZones = []

            if cfResults['success'] == true

                store_cf_response(cfResults['result'])

                cfResults['result'].each do |dnsRecord|
                    h = { 'record' => dnsRecord['name'], 'value' => dnsRecord['content'], 'type' => dnsRecord['type'] }

                    unless dnsRecord['priority'].nil?
                        # puts('priority is SET!')
                        h['priority'] = dnsRecord['priority']
                    end

                    # h['priority'] =

                    matchingCFZones.push(h)
                end

            end
            ## DEBUG
            # puts '----'
            # puts matchingCFZones
            # puts '----'
            # matchingCFZones
            #
            return matchingCFZones
        end # end process_response


        def store_cf_response(object)

            if(@CFResponseObject != nil)
                @CFResponseObject = @CFResponseObject+object
            else
                @CFResponseObject = object
            end

        end # add_cf_response

        def get_cf_record_id(record)

            searchResult = @CFResponseObject.select { |x| (x['record'] == record['record']) && (x['type'] == record['type']) && (x['value'] == record['value']) }
            return searchResult['id']

        end

    end # end CFAPIQuery class




    ##################
    #
    # FUNCTION
    # Input: TODO
    # Return: json responsed
    # Purpose: run commands against dream host api
    #
    ##################
    def dh_api_query(command, params = ''); end
end
