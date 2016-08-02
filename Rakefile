require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.pattern = ['manifests/*.pp', 'manifests/**/*.pp']
  config.disable_checks = [ '80chars', 'selector_inside_resource', 'documentation' ]
  config.with_filename = true
  config.with_context = true
  config.fail_on_warnings = true
end

Rake::Task[:spec_standalone].clear
RSpec::Core::RakeTask.new(:spec_standalone) do |t|
  t.rspec_opts = ['--color']
  t.exclude_pattern = 'spec/fixtures/**/*'
  t.pattern = 'spec/**/*_spec.rb'
end

Rake::Task[:spec_prep].clear
desc 'Create the fixtures directory'
task :spec_prep do
  FileUtils::mkdir_p('spec/fixtures/modules/bigcommerce_soe')
  FileUtils::mkdir_p('spec/fixtures/manifests')
  FileUtils.chdir('spec/fixtures/modules/bigcommerce_soe') do
    %w(files manifests templates).each do |dir|
      FileUtils::ln_sf("../../../../#{dir}", '.')
    end
  end
  FileUtils::touch('spec/fixtures/manifests/site.pp')
  sh 'librarian-puppet install --path=spec/fixtures/modules'
end

Rake::Task[:spec_clean].clear
desc 'Clean up the fixtures directory'
task :spec_clean do
  #sh 'librarian-puppet clean'
  if File.zero?('spec/fixtures/manifests/site.pp')
    FileUtils::rm_f('spec/fixtures/manifests/site.pp')
  end
end
