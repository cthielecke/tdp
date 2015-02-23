# encoding: utf-8
require_relative 'system_functions.rb'

module TDP

  class Keyword
    include TDP::SystemFunctions
    include TDP::UserFunctions
    attr_reader :library_handler, :name, :action
    attr_accessor :parent
    
    def initialize( args )
      @library_handler = args[:library_handler]
      @name = args[:name]
      @action = args[:action]
      @parent = nil
    end
    
    class << self
      attr_reader :allowed_keywords
      # Class method to define allowed keywords for a subclass,
      # keywords/methods must match class names.
      def keywords( *args )
        @allowed_keywords = Array([*args])
      end
    end
    
    # Returns true if mthd can be handled by the class/subclass
    def allowed?(mthd)
      return true if self.class.allowed_keywords.include?(mthd)
      false
    end
    
    # Merge instance variables of source to those of this object
    def merge_instance_variables(source)
      source.instance_variables.each do |varname|
        val = source.instance_variable_get(varname)
        instance_variable_set(varname, val) unless instance_variable_defined?(varname)
      end
    end
    
    # Write the text generated up to now from buffer into file
    def write_file( fname )
      File.open(fname, "w") do |f|
        f << TDP.application.result
      end
      TDP.application.result = String.new
#      puts "...written to #{fname}"
    end
    
    # Resend method as private function if method/keyword is allowed for the object,
    # call "super" otherwise.
    def method_missing(mthd, *args, &blk)
      super unless allowed?(mthd)
      library = library_handler[mthd.capitalize.to_sym]
      send("_#{mthd}_", library, *args, &blk)
    end
    
    private
    
    # Method to handle the "task" keyword:
    # Gets instance, merges instance variables and 
    # evaluates the defined action in the instances scope
    def _task_( library, name, &params )
      item = library.get(name)
      item.parent = self
      item.merge_instance_variables(self)
      item.instance_eval(&params) if block_given?
      item.generate
    end
    
    # Method to handle the "template" keyword:
    # Gets instance, merges instance variables and 
    # evaluates the defined action in the instances scope
    alias_method :_template_, :_task_ 
    
    # Method to handle the "config" keyword:
    # Gets Config instance and evaluates the block (if given) and  
    # the defined action in the context of the actual object.
    def _config_( library, name, &params )
      item = library.get(name)
      action = item.action
      instance_eval(&params) if block_given?
      instance_eval(&action) unless action.nil?
    end
    
  end

  # Implements tasks supporting keywords "task", "template" and "config"
  #
  # Example:
  #   task "taskname" do
  #     ... some Ruby code
  #   end
  #
  class Task < Keyword
    keywords :task, :template, :config

    # Evaluate the action defined for this object
    def generate
      instance_eval(&action) if action
    end

  end

  # Implements templates supporting only keyword "config"
  #
  # Example:
  #   template "template_name" do
  #     ... some Ruby code
  #   end
  #
  class Template < Keyword
    keywords :config

    # Evaluate the associated template
    def generate( result = TDP.application.result, loader = TDP, engine_class = TDP::Engine)

      # Templates defined in tdp files must have actions which evaluate 
      # to single quoted strings.
      # Input for the template engine is provided by a blankslate instance
      # evaluation of the action or by loading the corresponding file
      #
      if action
        source = BasicObject.new.instance_eval(&action)
      else
        source = loader.load_template(name)
      end
      engine = engine_class.new(name: name, source: source)
      # Convert and generate with self as context
      engine.convert
      result << engine.generate(self)
    end

  end

  # Implements configurations supporting only keyword "config"
  #
  # Example:
  #   config "conf_name" do
  #     ... some Ruby code like 
  #       - assignments to instance variables
  #       - calls of other configurations
  #   end
  #
  class Config < Keyword
    keywords :config
  end

end
