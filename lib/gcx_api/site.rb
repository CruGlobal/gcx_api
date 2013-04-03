require '../validators/gcx_site_name_validator'

class GcxApi::Site
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  DEFAULTS = {privacy: 'public',
              theme: 'amped'}

  alias_method :save, :create

  attr_accessor :name, :title, :privacy, :theme, :sitetype, :attributes

  validates :name, presence: true, gcx_site_name: true, format: /^[a-z][a-z0-9_\-]{2,79}$/i
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
    ticket = GcxApi::Cas.get_cas_service_ticket(create_endpoint)

    res = RestClient::Request.execute(:method => :post, :url => create_endpoint + '?ticket=' + ticket, :payload => parameters, :timeout => -1) { |response, request, result, &block|
                                                                                                                                             ap request
                                                                                                                                             ap result.inspect
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

  def persisted?
    @persisted
  end
end
