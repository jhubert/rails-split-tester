require 'split_tester/railtie'
require 'split_tester/controller'
require 'split_tester/translation_helper'
require 'split_tester/caching'

module SplitTester
  class Base
    # Doesn't have access to Rails.root here
    begin
      SPLIT_TESTS = YAML.load_file("config/split_tests.yml")
      SPLIT_TESTS.keys
      LOADED = true
    rescue LoadError
      puts "[SplitTester] Missing config/split_tests.yml"
      LOADED = false
    rescue
      puts "[SplitTester] Invalid config/split_tests.yml"
      LOADED = false
    end

    def self.setup
      if LOADED
        # Add the split test language files to the load path
        I18n.load_path += Dir[Rails.root.join('test', 'split', '*', 'locale.{rb,yml}')]

        @@preprocessed_pathsets = begin
          self.test_keys.inject({}) do |pathsets, slug|
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
      else
        @@split_test_map = []
        @@preprocessed_pathsets = []
      end
    end

    def self.split_test_map
      @@split_test_map
    end

    def self.test_keys
      @test_keys ||= SPLIT_TESTS.keys.reject { |k| k == 'BASELINE' }
    end

    def self.preprocessed_pathsets
      @@preprocessed_pathsets
    end

    def self.custom_view_path(name)
      name == "views" ? "app/views" : "test/split/#{name}/views"
    end

    def self.active_test?(key)
      return false unless LOADED
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