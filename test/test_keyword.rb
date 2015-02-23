# setup stubs for included modules
module TDP
  module SystemFunctions
  end
  module UserFunctions
  end
end

require 'helper'
require_relative '../lib/tdp/keywords'

# These tests only provide assertions for the upper most DSL layer.
# As this is only a thin wrapper, all validations will be done elsewhere.
class TestKeyword < MiniTest::Unit::TestCase

	# def setup
		# $mock = MiniTest::Mock.new
	# end

  # def TDP.application
    # $mock
  # end
	
	def test_initialize
    ip1, ip2, ip3 = %w(handler, init, go)
    kw = TDP::Keyword.new( library_handler: ip1, name: ip2, action: ip3 )
    assert_equal( ip1, kw.library_handler )
    assert_equal( ip2, kw.name )
    assert_equal( ip3, kw.action )
    refute( kw.parent)
    # parent may be written, too
    kw.parent = ip1
    assert_equal( ip1, kw.parent )
	end
  
  def test_class_allowed
    # no keywords allowed
    kwclass = Class.new(TDP::Keyword)
    # check for no definition
    refute kwclass.allowed_keywords
    
    # some keywords allowed
    kwclass = Class.new(TDP::Keyword) do
      keywords :doom, :hl2
    end
    kw = kwclass.new( Hash.new )
    assert kw.allowed?(:doom)
    assert kw.allowed?(:hl2)
    refute kw.allowed?(:config)
  end

  def test_merge_instance_variables
    # create source object with single instance variable
    src = Object.new
    src.instance_variable_set(:@myvar, 99)
    kw = Class.new(TDP::Keyword).new( Hash.new )
    kw.merge_instance_variables( src )
    assert_includes( kw.instance_variables, :@myvar)
    assert_equal(99, kw.instance_variable_get(:@myvar))
  end
  
  # classes for use with method missing test
  TDP::Foo = Class.new(TDP::Keyword) do
    keywords :bar
    def _bar_( lh, *args )
      "bar called with args = #{args}"
    end
  end
  TDP::Bar = Class.new

  def test_method_missing
    lh = TDP::LibraryHandler.new(:Bar)
    kw = TDP::Foo.new( library_handler: lh )
    # keyword not allowed
    assert_raises( NoMethodError ) do
      kw.foo
    end
    # keyword allowed
    response = kw.bar
    assert_equal( 'bar called with args = []', response )
    response = kw.bar :my_name
    assert_equal( 'bar called with args = [:my_name]', response )
  end
    
end
