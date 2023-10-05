# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
end

require 'rake/extensiontask'

task build: :compile

Rake::ExtensionTask.new('bert') do |ext|
  ext.ext_dir = 'ext/bert/c'
  ext.lib_dir = 'lib/bert/c'
  ext.name = 'decode'
end

task default: %i[clobber compile test]
