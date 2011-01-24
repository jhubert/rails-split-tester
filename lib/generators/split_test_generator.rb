require 'rails/generators'

class SplitTestGenerator < Rails::Generators::NamedBase
  argument :size, :type => :string, :default => '0', :banner => "size"
  argument :description, :type => :string, :default => 'Your Test Description', :banner => "description"
  source_root File.expand_path('../templates', __FILE__)

  def manifest
    append_to_file('config/split_tests.yml', "#{name}:\n  description: #{description}\n  size: #{size}\n")
  end
end
