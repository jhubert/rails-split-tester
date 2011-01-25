# Change the namespace for caching if the current request
# is a split test so that caches don't get mixed together
module SplitTester #:nodoc:
  module Caching
    def self.included(base)
      base.class_eval {
        def fragment_cache_key(key, namespace = nil)
          namespace ||= is_split_test? ? "views-split-#{current_split_test_key}" : :views
          ActiveSupport::Cache.expand_cache_key(key.is_a?(Hash) ? url_for(key).split("://").last : key, namespace)
        end

        def expire_fragment(key, options = nil)
          return unless cache_configured?
          key = fragment_cache_key(key, :views) unless key.is_a?(Regexp)
          message = nil

          instrument_fragment_cache :expire_fragment, key do
            if key.is_a?(Regexp)
              cache_store.delete_matched(key, options)
            else
              cache_store.delete(key, options)
            end
          end

          unless key.is_a?(Regexp)
            original_key = key.dup
            SplitTester::Base.test_keys.each do |k,v| 
              key = original_key.sub('views/', "views-split-#{k}/")
              instrument_fragment_cache :expire_fragment, key do
                cache_store.delete(key, options)
              end
            end
          end
        end
      }
    end
  end
end