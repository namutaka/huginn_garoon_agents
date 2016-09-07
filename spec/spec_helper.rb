require 'vcr'

base_path = File.expand_path('../', __FILE__)

VCR.configure do |c|
  c.cassette_library_dir = "#{base_path}/vcr"
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  #c.default_cassette_options = { record: :new_episodes}
  #c.configure_rspec_metadata!
end

