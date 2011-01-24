require 'rails/generators'

class SplitTesterInstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def manifest
    empty_directory('test/split/')
    template('split_tests.yml', 'config/split_tests.yml')
  end
end
