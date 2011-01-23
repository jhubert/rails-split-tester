module SplitTester
  module ClassMethods
    def self.random_test_key
      split_test_map.sample
    end

    private

    def self.split_test_map
      @@split_test_map
    end

    def self.preprocessed_pathsets
      @@preprocessed_pathsets
    end
  end
end