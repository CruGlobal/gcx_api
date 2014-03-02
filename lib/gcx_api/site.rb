require File.expand_path("../../validators/gcx_site_name_validator", __FILE__)

class GcxApi::Site
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  DEFAULTS = {privacy: 'public',
              theme: 'amped'}

  attr_accessor :name, :title, :privacy, :theme, :sitetype, :base_url, :attributes

  validates :name, presence: true, gcx_site_name: true, format: /\A[a-z][a-z0-9_\-]{2,79}\z/i
  validates :title, presence: true

  def initialize(attributes = {})
    @attributes = DEFAULTS.merge(attributes)

    @attributes.each do |name, value|
      send("#{name}=", value)
    end

    @persisted = false
  end

  def create_endpoint
    GcxApi.gcx_url + "/wp-gcx/create-community.php"
  end

  def create
    parameters = attributes.to_json
    ticket = GcxApi::Cas.new.get_cas_service_ticket(create_endpoint)

    res = RestClient::Request.execute(:method => :post, :url => create_endpoint + '?ticket=' + ticket, :payload => parameters, :timeout => -1) { |response, request, result, &block|
                                                                         Rails.logger.debug request
                                                                         Rails.logger.debug result.inspect
                                                                          # check for error response
                                                                         if [301, 302, 307].include? response.code
                                                                           response.follow_redirection(request, result, &block)
                                                                         elsif response.code.to_i != 200
                                                                           raise response.headers.inspect + response.inspect
                                                                         end
                                                                         response.to_str
    }
    community = JSON.parse(res)
    if community['errors']
      raise community.inspect
    else
      @persisted = true
      return self
    end
  end

  def set_option_values(options)
    options_endpoint = GcxApi.gcx_url + '/' + name + '/index.php'

    RestClient::Request.execute(:method => :post, :url => options_endpoint + '?key=' + GcxApi.key, :payload => options, :timeout => -1) { |response, request, result, &block|
      Rails.logger.debug request
      Rails.logger.debug result.inspect
      # check for error response
      if response.code.to_i != 200
        raise response.headers.inspect + response.inspect
      end
      response.to_str
    }
  end


  def destroy(site_name)
    destroy_endpoint = GcxApi.gcx_url + "/#{site_name}/wp-gcx/delete-community.php"

    ticket = GcxApi::Cas.new.get_cas_service_ticket(destroy_endpoint)

    res = RestClient::Request.execute(:method => :post, :url => destroy_endpoint + '?ticket=' + ticket, :payload => {}, :timeout => -1) { |response, request, result, &block|
                                                                           Rails.logger.debug request
                                                                           Rails.logger.debug result.inspect
                                                                            # check for error response
                                                                           if response.code.to_i != 200
                                                                             raise result.inspect
                                                                           end
                                                                           response.to_str
    }
  end

  def persisted?
    @persisted
  end
end
