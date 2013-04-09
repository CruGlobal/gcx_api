require 'rest-client'
Dir[File.dirname(__FILE__) + '/gcx_api/*.rb'].each do |file|
  require file
end

module GcxApi
  class << self
    attr_accessor :gcx_url, :cas_url, :cas_username, :cas_password

    def config
      yield self

      self.gcx_url ||= 'https://wpdev.gcx.org'
      self.cas_url ||= 'https://casdev.gcx.org'
    end
  end
end
