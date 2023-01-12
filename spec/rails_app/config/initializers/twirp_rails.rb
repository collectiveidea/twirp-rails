# Require any _twirp.rb files in lib
Dir.glob(Rails.root.join("lib", "*_twirp.rb")).sort.each { |file| require file }
