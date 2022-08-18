desc "Checks for unapplied swagger documentation specs"
task check_swaggerization: :environment do
  require "digest/sha1"

  swagger_root = Rswag::Api.config.swagger_root
  files = Dir.glob("#{swagger_root}/**/*.yaml")

  puts ">>>>>>>>> swagger root #{swagger_root} #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
  puts ">>>>>>>>>  files #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
  pp files

  current_digests = files.each_with_object([]) do |file, digests|
    digests << Digest::SHA1.hexdigest(File.read(file))
  end
  puts ">>>>>>>>> current digest #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
  pp current_digests

  system("bundle exec rails rswag:specs:swaggerize", %i[err out] => File::NULL)

  new_digests = files.each_with_object([]) do |file, digests|
    digests << Digest::SHA1.hexdigest(File.read(file))
  end

  puts ">>>>>>>>> new digersts #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
  pp new_digests

  if new_digests != current_digests
    raise StandardError, "Swagger document generation detected unapplied changes"
  end
end
