SPEC = Gem::Specification.new do |spec|
  # Required gemspec attributes
  spec.files       = Dir.glob("**/*")
  spec.name        = "ruby-goldilocks"
  spec.summary     = "Ruby Driver for GOLDILOCKS"
  spec.version     = "21.1.5"

  #Recommended gemspec attributes
  spec.author      = "SUNJESOFT Inc."
  spec.description = "This Ruby driver provides a Ruby interface for GOLDILOCKS."
  spec.email       = "sunjesoft@sunjesoft.com"
  spec.homepage    = "http://www.sunjesoft.com"
  spec.licenses    = "MIT"

  #Optional gemspec attributes
  spec.extensions    = ["ext/extconf.rb"]
  spec.require_paths = ["lib"]
end
