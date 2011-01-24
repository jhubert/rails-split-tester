require 'split_tester'

module SplitTester
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer "split_tester.init" do
        SplitTester::Railtie.insert
      end
    end
  end

  class Railtie
    def self.insert
      ActionController::Base.send(:include, SplitTester::Controller)
      ActionController::Caching::Fragments.send(:include, SplitTester::Caching)
      ActionView::Helpers::TranslationHelper.send(:include, SplitTester::TranslationHelper)

      SplitTester::Base.setup
    end
  end
end