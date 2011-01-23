# Install hook code here
require 'fileutils'

#Copy the Javascript files
FileUtils.copy(File.dirname(__FILE__) + '/files/split_tests.yml', File.dirname(__FILE__) + '/../../../config/')

FileUtils.mkdir_p(File.dirname(__FILE__) + '/../../../test/split/')