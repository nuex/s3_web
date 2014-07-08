s3_web
======

S3 Website provisioning with Rake integration.

## Install

    bundle install

## Usage

In your Rakefile:

    require_relative 'lib/s3_web'
    require_relative 'lib/s3_web/rake'

    # Set your fog credentials from your .fog file
    Fog.credential = :aws_account

    # Provision a website
    website 'nu-ex.com'

    # Redirect www.nu-ex.com to nu-ex.com
    redirect 'www.nu-ex.com', 'nu-ex.com'

Then to create the configured website:

    bundle exec rake web:nu-ex.com:create
 
And to create a redirect:

    bundle exec rake redirect:www.nu-ex.com:create

## Rake commands

    rake redirect:www.website.com:create   # Create the S3 Redirect
    rake redirect:www.website.com:destroy  # Destroy the S3 Redirect
    rake redirect:www.website.com:status   # Show the status of the S3 redirect
    rake web:website.com:create            # Create an S3 Website Bucket
    rake web:website.com:destroy           # Destroy the S3 Website Bucket
    rake web:website.com:status            # Show the status of the S3 Website bucket
