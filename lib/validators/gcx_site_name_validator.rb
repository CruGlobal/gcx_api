require 'ox'
class GcxSiteNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value =~ /^[a-z][a-z0-9_\-]{2,79}$/i
      res = RestClient.get(GcxApi.gcx_url + "/wp-gcx/check-name.php?name=#{value}")
      doc = Ox.parse(res)
      unless doc.nodes.first.attributes[:result] == 'true'
        record.errors[attribute] << "is already taken"
      end
    end
  end
end


