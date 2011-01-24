require 'rails_generator'
require 'rails_generator/commands'
 
module SplitTester #:nodoc:
  module Generator #:nodoc:
    module Commands #:nodoc:
      module Create
        def setup
          file("split_tests.yml", "definition.txt")
        end
      end
 
      module Destroy
        def setup
          file("split_tests.yml", "definition.txt")
        end
      end
 
      module List
        def setup
          file("split_tests.yml", "definition.txt")
        end
      end
 
      module Update
        def setup
          file("split_tests.yml", "definition.txt")
        end
      end
    end
  end
end
 
Rails::Generator::Commands::Create.send   :include,  SplitTester::Generator::Commands::Create
Rails::Generator::Commands::Destroy.send  :include,  SplitTester::Generator::Commands::Destroy
Rails::Generator::Commands::List.send     :include,  SplitTester::Generator::Commands::List
Rails::Generator::Commands::Update.send   :include,  SplitTester::Generator::Commands::Update
