lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
    s.name           = 'dreamflare'
    s.version        = '0.1'
    s.platform       = Gem::Platform::RUBY
    s.authors        = ['adcreare']
    s.email          = ['caveman@commscentral.net']
    s.homepage       = 'https://github.com/adcreare/dreamflare'
    s.licenses       = ['MIT']
    s.summary        = %q{ Tool to sync dreamhost DNS to Cloudflare }
    s.description    = %q{ Tool to sync DNS records from DreamHost over to Cloudflare
                        Allows you to run cloudflare in non-dreamhost intergrated mode
                        which leaves your DNS apex zone exposed}
    s.files          = Dir.glob("{bin,lib}/**/*")
    s.executables    = ['dreamflare']
    s.bindir         = 'bin'
    s.add_dependency('json')
    s.add_development_dependency('aruba')
    s.add_development_dependency('rake')
end
