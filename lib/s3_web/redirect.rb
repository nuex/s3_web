module S3Web
  class Redirect
    attr_reader :from
    attr_reader :to

    def initialize from, to
      @from = from
      @to = to
    end

    def ensure
      ensure_bucket
      ensure_redirect
    end

    def destroy
      if bucket=get_bucket
        bucket.destroy
      end
    end

    def provisioned? ; bucket_exists? ; end

    private

    def bucket_exists? ; get_bucket ; end

    def get_bucket
      @bucket ||= S3Web.storage.directories.get(from)
    end

    def ensure_bucket
      get_bucket || create_bucket
    end

    def create_bucket
      S3Web.storage.directories.create(key: from, public: true, location: S3Web.region)
    end

    def ensure_redirect
      config = {'RedirectAllRequestsTo' => {'HostName' => to}}
      S3Web.storage.put_bucket_website from, config
    end
  end
end
