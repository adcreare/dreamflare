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

            # loop for each master dns record
            @MasterDNSRecords.each do |dhRecord|

                # find any slave records that match this master record
                searchResult = @SlaveDNSRecords.select { |x| (x['record'] == dhRecord['record']) && (x['type'] == dhRecord['type']) }
                resultLength = searchResult.length

                # if we don't find any matches then the record doesn't exist so create it
                if resultLength == 0

                    puts 'record does not exist - creating new record in CloudFlare'

                    if defined?(dhRecord['priority'])
                        cloudFlare.create_record(dhRecord['record'], dhRecord['type'], dhRecord['value'], dhRecord['priority'])
                    else
                        cloudFlare.create_record(dhRecord['record'], dhRecord['type'], dhRecord['value'])
                    end

                    puts 'created: ' + dhRecord['record'] + ' => ' + dhRecord['value']

                end

                if resultLength == 1
                    # must be a single record

                        # check if the values match on the record
                        if searchResult[0]['value'] != dhRecord['value']
                            puts 'single records do not much - update required ' + searchResult[0]['record']

                        else
                            puts 'records match - single value dns record - no action needed: ' + searchResult[0]['record']

                        end

                end


                # record must exist

                if resultLength > 1
                    # found match now what?
                    # - we will have ot check if the value mathces what we have
                    # if it doesn't update it

                    # check match multiple records could have been returned for example MX records with multiple values


                    # get both records from dreamhost (we reference on the 0 index but this would be the same for n values)
                    # this is for things like MX records where the record value(dns name) and the type will match
                    searchDHResults = @MasterDNSRecords.select { |x| (x['record'] == searchResult[0]['record']) && (x['type'] == searchResult[0]['type']) }

                    # for each of the DH records
                    searchDHResults.each do |dhRecordItem|
                        foundMatch = false

                        # check if that record exists and its matched in the slave records
                        searchResult.each do |cfRecordItem|
                            foundMatch = true if dhRecordItem == cfRecordItem
                        end


                        ## TODO
                        # Check how many record and and types exists on either side
                        # if the number doesn't match and is more on the master side go create the record on the slaveDNSrecords
                        # if the number is more on the slave side than the master find out which one doesn't match and delete it
                        #

                        # if we can't find a match better create!
                        if !foundMatch
                            puts('dual records - GO CREATE RECORD - Multiple records exist')
                        else
                            # puts("Multi record: no need to create duplicate record - already matches")
                            puts 'records match - multi value dns record - no action needed: ' + dhRecord['record']
                        end
                    end # end loop for searchDHResults

                end #end if




            end # end loop

        end # end perform_compare


    end # end class def


end #end module
