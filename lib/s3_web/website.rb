module S3Web
  class Website
    attr_reader :name

    def initialize name
      @name = name
      @domain = "#{name}."
      @record_name = name
    end

    def ensure
      ensure_bucket
      ensure_policy
      ensure_website_configuration
      ensure_zone
    end

    def destroy
      if bucket=get_bucket
        bucket.destroy
      end
    end

    def provisioned?
      [bucket_exists?, zone_exists?, record_exists?].all?
    end

    private

    def s3_zones
      return @zones if @zones
      data = File.join(File.dirname(__FILE__), 'data', 'zone_ids.yml')
      @zones = YAML.load_file(data)
      @zones
    end

    def bucket_exists? ; get_bucket ; end
    def zone_exists? ; get_zone ; end
    def record_exists? ; get_record ; end

    def ensure_bucket
      get_bucket || S3Web.storage.directories.create(key: name, public: true,
                                                     location: S3Web.region)
    end

    def get_bucket
      @bucket ||= S3Web.storage.directories.get(name)
    end

    def ensure_policy
      policy = {'Version' => '2012-10-17',
                'Statement' => [{'Sid' => 'AddPerm', 'Effect' => 'Allow',
                                 'Principal' => {'AWS' => '*'},
                                 'Action' => ['s3:GetObject'],
                                 'Resource' => ["arn:aws:s3:::#{name}/*"]}]}
      S3Web.storage.put_bucket_policy name, policy
    end

    def ensure_website_configuration
      S3Web.storage.put_bucket_website name, 'index.html'
    end

    def ensure_zone
      zone = get_zone
      unless zone
        zone = S3Web.dns.zones.new(domain: @domain)
        zone.save
      end
      return if record_exists?
      # Retrieve zone id from list of AWS S3 hosted zone ids
      zone_id = s3_zones[S3Web.region]
      # Build the bucket's website location
      location = "s3-website-#{S3Web.region}.amazonaws.com"
      # Create the change batch for creating an Alias record
      record_info = {action: 'CREATE', name: @record_name, type: 'A', ttl: 330,
                     alias_target: {hosted_zone_id: zone_id,
                                    dns_name: location}}
      # Create ALIAS Record
      zone.records.create record_info
    end

    def get_zone
      S3Web.dns.zones.select {|z| z.domain == @domain }.first
    end

    def get_record
      if zone=get_zone
        zone.records.find {|r| matching_record?(r) }
      end
    end

    def matching_record? record
      record.type == 'A' && record.name == @domain
    end
  end
end
