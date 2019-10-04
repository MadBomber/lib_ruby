# lib/ruby/s3_store.rb
# https://stackoverflow.com/questions/50868825/is-there-a-way-to-write-a-file-to-s3-in-ruby-or-rails

# check out https://www.ironin.it/blog/manipulating-files-on-amazon-s3-storage-with-rubys-fog-gem.html
# for a "fog" based approach.

# TODO: rewrite this using the "fog-aws" gem


# require the gem 'aws-sdk'

# Example Usage:
#   image = S3Store.new(File.read(path_to_file)).store
#
# This method presuposes that the content to be written to S3
# current exists in a file on the local filesystem.

class S3Store
 TEST = "app-uploads".freeze

 def initialize file
  @file = file
  @s3 = AWS::S3.new
  @bucket = @s3.buckets[TEST]
 end

 def store
  @obj = @bucket.objects[filename].write(@file.tempfile, acl: :public_read)
  self
 end

 def url
  @obj.public_url.to_s
 end

 private

 def filename
  # FIXME: @file is a string.  It has no `original_filename` method
  @filename ||= @file.original_filename.gsub(/[^a-zA-Z0-9_\.]/, '_')
 end
end

__END__

# https://docs.aws.amazon.com/AmazonS3/latest/dev/UploadObjSingleOpRuby.html

# This is only for files less than 5Gb in size.

# AWS Documentation » Amazon Simple Storage Service (S3) » Developer Guide » Working with Amazon S3 Objects » Operations on Objects » Uploading Objects » Uploading Objects in a Single Operation » Upload an Object Using the AWS SDK for Ruby
# Upload an Object Using the AWS SDK for Ruby

# The AWS SDK for Ruby - Version 3 has two ways of uploading an object to Amazon S3. The first uses a managed file uploader, which makes it easy to upload files of any size from disk. To use the managed file uploader method:

#     Create an instance of the Aws::S3::Resource class.

#     Reference the target object by bucket name and key. Objects live in a bucket and have unique keys that identify each object.

#     Call#upload_file on the object.

require 'aws-sdk-s3'

s3 = Aws::S3::Resource.new(region:'us-west-2')
obj = s3.bucket('bucket-name').object('key')
obj.upload_file('/path/to/source/file')

# The second way that AWS SDK for Ruby - Version 3 can upload an object uses the #put method of Aws::S3::Object. This is useful if the object is a string or an I/O object that is not a file on disk. To use this method:

#     Create an instance of the Aws::S3::Resource class.

#     Reference the target object by bucket name and key.

#     Call#put, passing in the string or I/O object.

require 'aws-sdk-s3'

s3 = Aws::S3::Resource.new(region:'us-west-2')
obj = s3.bucket('bucket-name').object('key')

# I/O object
File.open('/path/to/source.file', 'rb') do |file|
  obj.put(body: file)
end

##########################################################
# https://docs.aws.amazon.com/AmazonS3/latest/dev/uploadobjusingmpu-ruby-sdk.html

# This covers up to 5 Tb of file size.

