# Change the namespace for caching if the current request
# is a split test so that caches don't get mixed together
module SplitTester #:nodoc:
  module Caching
    def self.included(base)
      base.class_eval {
        def fragment_cache_key(key)
          namespace = is_split_test? ? "views-split-#{current_split_test_key}" : :views
          ActiveSupport::Cache.expand_cache_key(key.is_a?(Hash) ? url_for(key).split("://").last : key, namespace)
        end
      }
    end
  end
end