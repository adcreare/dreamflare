module Dreamflare
    def load_config
        filepath = File.expand_path('~/dreamflare/config.rb')
        if File.file?(filepath)
            require '~/dreamflare/config.rb'
        else
            puts 'Unable to load config file. Does ~/dreamflare/config.rb exist?'
            exit
        end
    end
end
