require 'fog/aws'
require_relative 's3_web/website'
require_relative 's3_web/redirect'

module S3Web
  # Set the region from the defined credentials, or default to
  # us-east-1 (standard).
  def self.region
    Fog.credentials[:region] || 'us-east-1'
  end

  def self.storage
    endpoint = "http://s3-#{region}.amazonaws.com"
    fog_options = Fog.credentials.merge({provider: 'aws', path_style: true,
                                         endpoint: endpoint})
    Fog::Storage.new fog_options
  end

  def self.dns
    Fog::DNS[:aws]
  end
end
