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

        def perform_compare

            # loop for each master dns record
            @MasterDNSRecords.each do |dhRecord|

                # find any slave records that match this master record
                srOfSlaveMatchingMasterRecord = @SlaveDNSRecords.select { |x| (x['record'] == dhRecord['record']) && (x['type'] == dhRecord['type']) }
                resultLength = srOfSlaveMatchingMasterRecord.length

                # if we don't find any matches then the record doesn't exist so create it
                if resultLength == 0
                    create_record(dhRecord)
                end

                if resultLength == 1 # single record only
                    # check if the values match on the record
                    if srOfSlaveMatchingMasterRecord[0]['value'] != dhRecord['value']
                        puts 'single records do not much - update required ' + srOfSlaveMatchingMasterRecord[0]['record']
                        update_record(dhRecord)
                    else
                        puts 'records match - single value dns record - no action needed: ' + srOfSlaveMatchingMasterRecord[0]['record']
                    end
                end

                if resultLength > 1 # multiple matches - must be an mx or cname record that has multiple values
                    multiple_record_processor(dhRecord, srOfSlaveMatchingMasterRecord)
                end
            end # end loop for each master record
        end # end perform_compare

        ##############################################
        ##############################################
        private



        def multiple_record_processor(masterRecord,srOfSlaveMatchingMasterRecord)
            # Get all master values of this record
            srOfAllMasterRecordOfThisGroup = @MasterDNSRecords.select { |x| (x['record'] == masterRecord['record']) && (x['type'] == masterRecord['type']) }

            # for each of the master records
            srOfAllMasterRecordOfThisGroup.each do |eachMasterRecord|
                foundMatch = false

                # check that one of the slave records matches the master record
                srOfSlaveMatchingMasterRecord.each do |cfRecordItem|
                    foundMatch = true if eachMasterRecord == cfRecordItem
                end

                # if we can't find a match better create!
                if !foundMatch
                    puts('dual records - GO CREATE RECORD - Multiple records exist')
                    puts masterRecord
                    create_record(masterRecord)
                else
                    puts 'records match - multi value dns record - no action needed: ' + masterRecord['record']
                end
            end # loop for each master record

            # we need to do a clean up and ensure all slave records exist in master
            multiple_record_update_cleanup(srOfAllMasterRecordOfThisGroup, srOfSlaveMatchingMasterRecord)

        end #end multiple_record_processor

        def multiple_record_update_cleanup(masterRecordArray, slaveRecordArray)
            slaveRecordArray.each do |slaveRecord| # for each slave record ensure its got a matching master record
                recordFound = false
                masterRecordArray.each do |masterRecord|
                    recordFound = true if masterRecord == slaveRecord
                end
                # if we didn't find this record in the master set we'd better delete it!
                delete_record(slaveRecord) unless recordFound
            end
        end # multiple_record_update_cleanup

        # TODO implement delete
        def delete_record(record)
            puts "removing old record - in multiple record processing"
            @ClassOfProviderToUpdate.delete_record(record)
        end

        # Takes a record to update and passes it back to the slave provider class
        def update_record(record)
            @ClassOfProviderToUpdate.update_record(record)
        end

        # Takes a record and will use the slave provider to update it
        def create_record(record)
            puts 'record does not exist - creating new record in CloudFlare'
            puts record
            exit

            if defined?(record['priority'])
                @ClassOfProviderToUpdate.create_record(record['record'], record['type'], record['value'], record['priority'])
            else
                @ClassOfProviderToUpdate.create_record(record['record'], record['type'], record['value'])
            end

            puts 'created: ' + record['record'] + ' => ' + record['value']
        end
    end # end class def


end #end module
