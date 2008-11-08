task :default => :test

task :test do
  Dir["test/*_test.rb"].each { |file| load file }
end