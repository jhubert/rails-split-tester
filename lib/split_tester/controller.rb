module SplitTester
  module Controller

    def self.included(controller)
      controller.extend ClassMethods
    end

    # ---------------------------------------------------------------
    # Before Filters
    # ---------------------------------------------------------------

    # If a split_test_key other than BASELINE exists, add the proper
    # view path to the load paths used by ActionView
    def setup_split_testing
      @split_test_key = get_split_test_key
      return if @split_test_key == 'BASELINE' || @split_test_key.nil?
      split_test_path = preprocessed_pathsets[SplitTester::Base.custom_view_path(@split_test_key)]
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
        session[:split_test_key] = ApplicationController.random_test_key
        cookies[:split_test_key] = session[:split_test_key]
      end
      return session[:split_test_key]
    end

    # For caching, we need to add something to the cache_path
    # so that it caches each version of the page seperately.
    # Ideally, this would be added into the ActionCaching 
    # module directly so that you don't need to specify anything
    # in the caches_action command
    def custom_cache_path
      path = ActionCachePath.new(self).path
      path += ":#{@split_test_key}" if @split_test_key && @split_test_key != 'BASELINE'
      path
    end

    # ---------------------------------------------------------------
    # Class Variables
    # ---------------------------------------------------------------

    # preprocess some pathsets on boot
    # doing pathset generation during a request is very costly
    @@preprocessed_pathsets = begin
      SPLIT_TESTS.keys.reject { |k| k == 'BASELINE' }.inject({}) do |pathsets, slug|
        path = SplitTester::Base.custom_view_path(slug)
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
end