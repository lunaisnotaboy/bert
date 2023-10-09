# frozen_string_literal: true

require_relative 'lib/bert/version'

Gem::Specification.new do |spec|
  spec.name = 'bert'
  spec.version = BERT::VERSION

  spec.authors = ['Luna Nova', 'Tom Preston-Werner']
  spec.email = ['her@mint.lgbt', 'tom@mojombo.com']

  spec.description = 'BERT serialization for Ruby'
  spec.homepage = 'https://github.com/lunaisnotaboy/bert'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'
  spec.summary = 'BERT serialization for Ruby'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[
                        bench/
                        bin/
                        features/
                        spec/
                        test/
                        various/
                        .circleci
                        .editorconfig
                        .git
                        .rubocop.yml
                        .ruby-version
                        .vscode
                        appveyor
                        Gemfile
                        rubocop-schema.json
                      ])
    end
  end

  spec.extensions = ['ext/bert/c/extconf.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'mochilo', '~> 1.3'
end
