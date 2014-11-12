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
  
  module CSVFiles
 
    CSV::Converters[:blank_to_nil] = lambda do |field|
      field && field.empty? ? nil : field
    end

    # Read a CSV file into an array of hashes with the symbolized headers as keys
    # Column separator is a colon.
    def read_csv_with_header( path )
      File.open(path) do |f|
        csv = CSV.new(f, :col_sep => ';', :headers => true, :header_converters => :symbol, :converters => [:all, :blank_to_nil])
        csv.to_a.map {|row| row.to_hash }
      end
    end
    
  end
  
  module SystemFunctions
    include TDP::RandomThings
    include TDP::CSVFiles
	end
end