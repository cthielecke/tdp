require 'helper'
require_relative '../lib/tdp/application'

# These tests only provide assertions for the upper most DSL layer.
# As this is only a thin wrapper, all validations will be done elsewhere.
class TestDSL < MiniTest::Unit::TestCase
include TDP::DSL
include TDP

	def setup
		$mock = Minitest::Mock.new
	end

  def TDP.application
    $mock
  end
	
  # testing the import of a varying number of files, or even rubbish!
	def test_import_files
    fnsarray = [["afile", "bfile", "../cfile"], 
                "./adir/afile", 
                "", 
                [false, true, 1234],
                ]
    fnsarray.each do |fns|
      $mock.expect :add_import, true, [fns]
      import fns
      assert $mock.verify
    end
	end

	def test_import_without_argument
    # no expectations here because there are no files given
    import
    assert $mock.verify
	end
  
  def test_definition_of_class
    klasses = [ 'Task', 'Config', 'Template' ]
    klasses.each do |klass|
      $mock.expect :add_item, true, ["#{klass}".to_sym, "name", Proc]
      define "#{klass}".to_sym => "name" do
        puts "body of definition"
      end
      assert $mock.verify
    end
  end
    
end
