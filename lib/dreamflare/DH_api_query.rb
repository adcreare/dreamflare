module Dreamflare
    class DHAPIQuery
        @@APIKey = '' # private variable

        def initialize(apiKey)
            @@APIKey = apiKey
        end

        def uuid
            SecureRandom.uuid
        end

        def query(command, params = '')
            uri = URI("https://api.dreamhost.com/?key=#{@@APIKey}&cmd=#{command}&unique_id=#{uuid}&format=json#{params unless params.empty?}")

            puts 'calling API: ' + String(uri)
            connection = Net::HTTP.new(uri.host, uri.port)
            connection.use_ssl = true
            data = connection.get(uri.request_uri)

            responseObject = process_response(JSON.parse(data.body))

            responseObject
        end

        private

        def process_response(dhResults)
            matchingDHZones = []

            # if the result was a success from DH then for each record returned
            if dhResults['result'] == 'success'
                dhResults['data'].each do |dnsRecord| #
                    next unless dnsRecord['zone'] == SearchZone # See if it mathces our search zone

                    # If the value of the record has a space in it - its probably got a priority set
                    # go and cut that out if possible
                    if dnsRecord['value'].count(' ') > 0
                        resultOfSplit = dnsRecord['value'].split

                        # If weh have more than two spaces in the record we probably don't have a priority set
                        # so update as a normal record
                        if resultOfSplit.length > 2
                            h = { 'record' => dnsRecord['record'], 'value' => dnsRecord['value'].chomp('.'), 'type' => dnsRecord['type'] }
                        else

                            # Try and get an int out of the first char, if we can't and we still got this far there is something odd about this record
                            # Throw and error an move on
                            begin
                                priority = Integer(resultOfSplit[0])
                                h = { 'record' => dnsRecord['record'], 'value' => resultOfSplit[1].chomp('.'), 'type' => dnsRecord['type'], 'priority' => Integer(resultOfSplit[0]) }
                            rescue
                                puts ('*    unable to cast to interger the front value of the dns record from dreamhost: ' + dnsRecord['value'])
                                puts 'will skip record'
                            end

                        end

                    # Standard record add it to the matching records
                    else
                        h = { 'record' => dnsRecord['record'], 'value' => dnsRecord['value'].chomp('.'), 'type' => dnsRecord['type'] }
                    end

                    # Push into matching zones as long as something got set into h above, otherwise skip and keep going
                    matchingDHZones.push(h) unless h.nil?
                end
            end

            matchingDHZones
        end # end processResponse
    end # end DHAPIQuery

    ##################
    #
    # FUNCTION
    # Input: TODO
    # Return: json responsed
    # Purpose: run commands against dream host api
    #
    ##################
    def dh_api_query(command, params = ''); end
end # end module
