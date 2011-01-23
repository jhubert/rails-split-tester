require 'action_controller'

module ActionController #:nodoc:
  class Base

    SPLIT_TESTS = YAML.load_file("#{RAILS_ROOT}/config/split_tests.yml")

    class << self
      def custom_view_path(name)
        name == "views" ? "app/views" : "test/split/#{name}/views"
      end
      
      def self.random_test_key
        split_test_map.sample
      end
    end

    before_filter :setup_split_testing

    # preprocess some pathsets on boot
    # doing pathset generation during a request is very costly
    @@preprocessed_pathsets = begin
      SPLIT_TESTS.keys.reject { |k| k == 'BASELINE' }.inject({}) do |pathsets, slug|
        path = ActionController::Base.custom_view_path(slug)
        pathsets[path] = ActionView::Base.process_view_paths(path).first
        pathsets
      end
    end

    @@split_test_map = begin
      tm = {} # test map
      SPLIT_TESTS.each { |k, v| tm[k] = v['size'].to_i }
      tm.keys.zip(tm.values).collect { |v,d| (0...d).collect { v }}.flatten
    end

    cattr_accessor :preprocessed_pathsets, :split_test_map

    # If a split_test_key other than BASELINE exists, add the proper
    # view path to the load paths used by ActionView
    def setup_split_testing
      return unless is_split_test?
      split_test_path = preprocessed_pathsets[ActionController::Base.custom_view_path(@split_test_key)]
      prepend_view_path(split_test_path) if split_test_path
    end

    # Get the existing split_test_key from the session or the cookie.
    # If there isn't one, or if the one isn't a running test anymore
    # assign the user a new key and store it. 
    # Don't assign a key if it is a crawler. (This doesn't feel right)
    def get_split_test_key
      return params[:force_test_key] if params[:force_test_key] # just for testing
      return session[:split_test_key] if session[:split_test_key] && SPLIT_TESTS.has_key?(session[:split_test_key])
      return session[:split_test_key] = cookies[:split_test_key] if cookies[:split_test_key] && SPLIT_TESTS.has_key?(cookies[:split_test_key])
      if (request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i)
        session[:split_test_key] = nil
      else
        session[:split_test_key] = ActionController::Base.random_test_key
        cookies[:split_test_key] = session[:split_test_key]
      end
      return session[:split_test_key]
    end

    def current_split_test_key
      @split_test_key ||= get_split_test_key
    end

    def is_split_test?
      current_split_test_key && current_split_test_key != 'BASELINE'
    end

    helper_method :is_split_test?, :current_split_test_key
  end
end

# Change the namespace for caching if the current request
# is a split test so that caches don't get mixed together
module ActionController #:nodoc:
  module Caching
    module Fragments
      def fragment_cache_key(key)
        namespace = is_split_test? ? "views-split-#{current_split_test_key}" : :views
        ActiveSupport::Cache.expand_cache_key(key.is_a?(Hash) ? url_for(key).split("://").last : key, namespace)
      end
    end
  end
end

# Overwrite the translate method so that it tries the bucket translation first
# TODO: There is probably a better way to write this
module ActionView
  module Helpers
    module TranslationHelper
      def translate(key, options = {})
        key = scope_key_by_partial(key)
        if is_split_test?
          # normalize the parameters so that we can add in 
          # the current_split_test_key properly
          scope = options.delete(:scope)
          keys = I18n.normalize_keys(I18n.locale, key, scope)
          keys.shift
          key = keys.join('.')

          # Set the standard key as a default to fall back on automatically
          if options[:default]
            options[:default] = [options[:default]] unless options[:default].is_a?(Array)
            options[:default].unshift(key.to_sym)
          else
            options[:default] = [key.to_sym]
          end

          key = "#{current_split_test_key}.#{key}"
        end
        translation = I18n.translate(key, options.merge!(:raise => true))
        if html_safe_translation_key?(key) && translation.respond_to?(:html_safe)
          translation.html_safe
        else
          translation
        end
      rescue I18n::MissingTranslationData => e
        keys = I18n.normalize_keys(e.locale, e.key, e.options[:scope])
        content_tag('span', keys.join(', '), :class => 'translation_missing')
      end
      alias t translate
    end
  end
end

# Add the split test language files to the load path
I18n.load_path += Dir[Rails.root.join('test', 'split', '*', 'locale.{rb,yml}')]