require 'action_view'

module SplitTester
  module TranslationHelper
    def self.included(base)
      # Using class_eval here because base.send(:include, InstanceMethods)
      # wasn't overwriting the translate method properly. Not sure why.
      base.class_eval {
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
      }
    end
  end
end