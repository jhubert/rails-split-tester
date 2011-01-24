require 'split_tester/railtie'
require 'split_tester/controller'
require 'split_tester/translation_helper'
require 'split_tester/caching'

module SplitTester
  class Base
    # Doesn't have access to Rails.root here
    SPLIT_TESTS = YAML.load_file("config/split_tests.yml")
    unless SPLIT_TESTS.is_a?(Hash)
      raise 'Invalid config/split_tests.yml file. Unable to parse the split tests.'
    end

    def self.setup
      # Add the split test language files to the load path
      I18n.load_path += Dir[Rails.root.join('test', 'split', '*', 'locale.{rb,yml}')]

      @@preprocessed_pathsets = begin
        SPLIT_TESTS.keys.reject { |k| k == 'BASELINE' }.inject({}) do |pathsets, slug|
          path = custom_view_path(slug)
          pathsets[path] = ActionView::Base.process_view_paths(path).first
          pathsets
        end
      end

      @@split_test_map = begin
        tm = {} # test map
        SPLIT_TESTS.each { |k, v| tm[k] = v['size'].to_i }
        tm.keys.zip(tm.values).collect { |v,d| (0...d).collect { v }}.flatten
      end
    end

    def self.split_test_map
      @@split_test_map
    end

    def self.preprocessed_pathsets
      @@preprocessed_pathsets
    end

    def self.custom_view_path(name)
      name == "views" ? "app/views" : "test/split/#{name}/views"
    end

    def self.active_test?(key)
      SPLIT_TESTS.has_key?(key)
    end

    def self.view_path(key)
      preprocessed_pathsets[custom_view_path(key)]
    end

    def self.random_test_key
      split_test_map.sample
    end
  end
end