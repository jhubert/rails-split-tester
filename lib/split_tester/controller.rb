module SplitTester #:nodoc:
  module Controller
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval {
        helper_method :is_split_test?, :current_split_test_key

        before_filter :setup_split_testing
      }
    end

    module InstanceMethods
      # If a split_test_key other than BASELINE exists, add the proper
      # view path to the load paths used by ActionView
      def setup_split_testing
        return unless is_split_test?
        split_test_path = SplitTester::Base.view_path(current_split_test_key)
        prepend_view_path(split_test_path) if split_test_path
      end

      # Get the existing split_test_key from the session or the cookie.
      # If there isn't one, or if the one isn't a running test anymore
      # assign the user a new key and store it. 
      # Don't assign a key if it is a crawler. (This doesn't feel right)
      def get_split_test_key
        return params[:force_test_key] if params[:force_test_key] && SplitTester::Base.active_test?(params[:force_test_key]) # just for testing
        return session[:split_test_key] if session[:split_test_key] && SplitTester::Base.active_test?(session[:split_test_key])
        return session[:split_test_key] = cookies[:split_test_key] if cookies[:split_test_key] && SplitTester::Base.active_test?(cookies[:split_test_key])
        if (request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i)
          session[:split_test_key] = nil
        else
          session[:split_test_key] = SplitTester::Base.random_test_key
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
    end
  end
end