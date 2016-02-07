# Tests
namespace :test do
  desc 'Test ForemanAnsible'
  Rake::TestTask.new(:foreman_ansible) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
  end
end

namespace :foreman_ansible do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_ansible) do |task|
        task.patterns = ["#{ForemanAnsible::Engine.root}/app/**/*.rb",
                         "#{ForemanAnsible::Engine.root}/lib/**/*.rb",
                         "#{ForemanAnsible::Engine.root}/test/**/*.rb"]
      end
    rescue
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_ansible'].invoke
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:foreman_ansible'].invoke
end

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance do
    Rake::Task['test:foreman_ansible'].invoke
    Rake::Task['foreman_ansible:rubocop'].invoke
  end
end
