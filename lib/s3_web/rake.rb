module S3Web 
  module Provision
    extend Rake::DSL
    include Rake::DSL

    def website name
      namespace "web:#{name}" do
        desc 'Show the status of the S3 Website bucket'
        task :status do
          web = S3Web::Website.new(name)
          puts (web.provisioned? ? 'up' : 'down')
        end

        desc 'Create an S3 Website Bucket'
        task :create do
          web = S3Web::Website.new(name)
          web.ensure
        end

        desc 'Destroy the S3 Website Bucket'
        task :destroy do
          web = S3Web::Website.new(name)
          web.destroy
        end
      end
    end

    def redirect from, to
      namespace "redirect:#{from}" do
        desc 'Show the status of the S3 redirect'
        task :status do
          redirect_bucket = S3Web::Redirect.new(from, to)
          puts (redirect_bucket.provisioned? ? 'up' : 'down')
        end

        desc 'Create the S3 Redirect'
        task :create do
          redirect_bucket = S3Web::Redirect.new(from, to)
          redirect_bucket.ensure
        end

        desc 'Destroy the S3 Redirect'
        task :destroy do
          redirect_bucket = S3Web::Redirect.new(from, to)
          redirect_bucket.destroy
        end
      end
    end
  end
end

include S3Web::Provision
