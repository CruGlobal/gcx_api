class GcxApi::User

  def self.create_endpoint(site_name)
    GcxApi.gcx_url + "/#{site_name}/wp-gcx/add-users.php"
  end

  def self.create(site_name, users)
    parameters = users.to_json
    service_url = GcxApi::User.create_endpoint(site_name)
    ticket = GcxApi::Cas.get_cas_service_ticket(service_url)

    res = RestClient::Request.execute(:method => :post, :url => service_url + '?ticket=' + ticket, :payload => parameters, :timeout => -1) { |response, request, result, &block|
                                      Rails.logger.ap request
                                      # check for error response
                                      if response.code.to_i == 400
                                        raise response.inspect
                                      end
                                      if response.code.to_i != 200
                                        raise result.inspect
                                      end
                                      response.to_str
    }
    JSON.parse(res)
  end
end

