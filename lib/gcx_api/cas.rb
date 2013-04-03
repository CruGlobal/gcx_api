class GcxApi::Cas

  def initialize(username = GcxApi.cas_username, password = GcxApi.cas_password)
    self.username = username
    self.password = password
  end

  def get_cas_service_ticket(service_url)
    parameters = {username: username,
                  password: password}
    location = RestClient::Request.execute(:method => :post, :url => GcxApi.cas_url + "/cas/v1/tickets", :payload => parameters, :timeout => -1) { |res, request, result, &block|
                                            # check for error response
                                            if response.code.to_i == 400
                                              raise res.inspect
                                            end
                                            res
    }.headers[:location]

    parameters = {service: service_url}
    ticket = RestClient::Request.execute(:method => :post, :url => location, :payload => parameters, :timeout => -1) { |res, request, result, &block|
                                          # check for error response
                                          if response.code.to_i != 200
                                            raise res.inspect
                                          end
                                          res
    }.to_str
    ticket
  end

end
