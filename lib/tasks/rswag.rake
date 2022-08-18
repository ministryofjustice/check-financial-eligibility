desc "Checks for unapplied swagger documentation specs"
task check_swaggerization: :environment do
  # require "digest/sha1"
  #
  # swagger_root = Rswag::Api.config.swagger_root
  # files = Dir.glob("#{swagger_root}/**/*.yaml")
  #
  # current_digests = files.each_with_object([]) do |file, digests|
  #   digests << Digest::SHA1.hexdigest(File.read(file))
  # end
  #
  # system("bundle exec rails rswag:specs:swaggerize", %i[err out] => File::NULL)
  #
  # new_digests = files.each_with_object([]) do |file, digests|
  #   digests << Digest::SHA1.hexdigest(File.read(file))
  # end
  #
  # if new_digests != current_digests
  #   raise StandardError, "Swagger document generation detected unapplied changes"
  # end
end
