# encoding: utf-8
module TDP
require 'forwardable'

  class LibraryHandler
    extend Forwardable
    def_delegators :@libraries, :each
    include Enumerable
    
    def initialize( *klasses )
      @libraries = {}
      klasses.each do |klass|
        libraries[klass] = Library.new(item_class: klass, library_handler: self)
      end
    end

    def defined?( klass )
      return true if libraries.include?(klass.to_sym)
      false
    end
    
    def libraries
      @libraries
    end
    
    def []( klass )
      libraries[klass.to_sym]
    end
    
    alias get []
    
  end

  class Library

    attr_reader :item_class, :library_handler
    
    def initialize( args )
      @item_class = TDP.const_get(args[:item_class])
      @library_handler = args[:library_handler]
    end
    
    def items
      @items ||= {}
    end
    
    def define( name, action )
      items[name.to_sym] = action
    end
    
    def get( name )
      sym = name.to_sym
  #    puts "getting #{name} of type #{item_class} from #{self}"
      item_class.new(library_handler: library_handler, name: name, action: items[sym])
    end
    
    def defined?( name )
      sym = name.to_sym
      return true if items.include?(sym)
      false
    end
    
  end 

end