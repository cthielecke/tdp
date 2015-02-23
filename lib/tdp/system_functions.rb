# encoding: utf-8
# Function library for TDP
require 'csv'

module TDP

  module RandomThings

    # Returns pseudo random surname
    def surname
      names = %w( Meier Müller Schulze Schmidt )
      names[rand(names.size)]
    end

    # Returns pseudo random fist name
    def firstname
      names = %w( Hugo Egon Erwin Silvio Angela Eva Carlo Günther )
      names[rand(names.size)]
    end
    
  end
  
  module UserModule
  end
  
  module SystemFunctions
    include TDP::RandomThings
  end
  
  module UserFunctions
    include TDP::UserModule
  end
  
end