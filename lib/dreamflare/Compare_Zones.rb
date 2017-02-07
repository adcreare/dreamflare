module Dreamflare

    class CompareZones

        @ClassOfProviderToUpdate = nil
        @MasterDNSRecords = nil
        @SlaveDNSRecords = nil

        def initialize(classOfProvider, masterDNSRecord, slaveDNSrecords)
            @ClassOfProviderToUpdate = classOfProvider
            @MasterDNSRecords = masterDNSRecord
            @SlaveDNSRecords = slaveDNSrecords
        end

        def perform_compare()

            # loop for each source record
            @MasterDNSRecords.each do |dhRecord|
                # find any CF records that match on DNS name and record type
                searchResult = @SlaveDNSRecords.select { |x| (x['record'] == dhRecord['record']) && (x['type'] == dhRecord['type']) }
                resultLength = searchResult.length

                if resultLength == 0

                    puts 'record does not exist - creating new record in CloudFlare'

                    if defined?(dhRecord['priority'])
                        cloudFlare.update_record(dhRecord['record'], dhRecord['type'], dhRecord['value'], dhRecord['priority'])
                    else
                        cloudFlare.update_record(dhRecord['record'], dhRecord['type'], dhRecord['value'])
                    end

                    puts 'created: ' + dhRecord['record'] + ' => ' + dhRecord['value']

                else # found match now what?
                    # puts(searchResult)

                    # check match multiple records could have been returned for example MX records
                    if resultLength > 1

                        searchDHResults = @MasterDNSRecords.select { |x| (x['record'] == searchResult[0]['record']) && (x['type'] == searchResult[0]['type']) }

                        searchDHResults.each do |dhRecordItem|
                            foundMatch = false
                            searchResult.each do |cfRecordItem|
                                foundMatch = true if dhRecordItem == cfRecordItem
                            end

                            # if we can't find a match better create!
                            if !foundMatch
                                puts('dual records - GO CREATE RECORD - Multiple records exist')
                            else
                                # puts("Multi record: no need to create duplicate record - already matches")
                                puts 'records match - multi value dns record - no action needed: ' + dhRecord['record']
                            end
                        end # end dual record handleing

                    else # must be a single record

                        # check if the values match on the record
                        if searchResult[0]['value'] != dhRecord['value']
                            puts 'single records do not much - update required ' + searchResult[0]['record']

                        else
                            puts 'records match - single value dns record - no action needed: ' + searchResult[0]['record']

                        end

                  end # en single record

              end # end record exists checks
            end

        end # end loop


    end # end class def


end #end module
