module TDP
require 'erubis'

# TODO
# use class instance variable as buffer for output
class Engine
attr_reader :name, :version, :source, :code, :engine

	def initialize( args )
		@name = args[:name]
		@version = args[:version]
		@source = args[:source]
    @code = nil
	end

  def convert( src=nil )
    @source ||= src
    if source
      @engine = Erubis::Eruby.new(source)
      code = engine.src
    else
      fail "Source not defined for template #{name}"
    end
  end
  
	def generate(context=nil)
		engine.evaluate(context)
	end

end

end