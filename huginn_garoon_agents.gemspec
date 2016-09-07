# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

INCLUDE_RAGOON = false

Gem::Specification.new do |spec|
  spec.name          = "huginn_garoon_agents"
  spec.version       = '0.1'
  spec.authors       = ["namutaka"]
  spec.email         = ["namutaka+g@gmail.com"]

  spec.summary       = %q{Write a short summary, because Rubygems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}

  spec.homepage      = "https://github.com/[my-github-username]/huginn_garoon_agents"

  spec.files         = Dir['LICENSE.txt', 'lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  #spec.test_files    = Dir['spec/**/*.rb']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "huginn_agent"

  unless INCLUDE_RAGOON
    spec.add_runtime_dependency "ragoon", ">= 0.6.0"

  else
    ragoon_spec = Dir.chdir('ragoon') {|p|
      Gem::Specification.load('ragoon.gemspec')
    }

    spec.files         += ragoon_spec.files.map {|f| File.join('ragoon', f) }
    spec.require_paths += ragoon_spec.require_paths.map {|f| File.join('ragoon', f) }

    depencds = spec.dependencies.map(&:name)
    ragoon_spec.dependencies.each do |gem|
      next if depencds.include?(gem.name)

      case gem.type
      when :runtime
        spec.add_runtime_dependency gem
      when :development
        spec.add_development_dependency gem
      end
    end
  end
end
