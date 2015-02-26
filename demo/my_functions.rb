# decimal computing
require 'bigdecimal'
require 'securerandom'
require 'logger'
require 'zip'

module TDP
  
  module UserModule
  
    # Shift the date for 'delta' days 
    def shift_date(actual_time, delta)
      actual_time + (60*60*24*delta.to_i)
    end
    
    # Calculate execution date in the format yyyy-mm-dd
    def calculate_exec_date( actual_time, user_value )
      uv = user_value.nil? ? 0 : user_value # set default value if none specified
      pos = uv.to_s =~ /^[+-]?[0-9]+$/
      if pos == 0 # this is a valid delta in number of days
        return shift_date(actual_time, uv.to_i).strftime("%F")
      end
      uv = nil if user_value == "empty"
      uv # this is the value if it's no delta
    end
    
    # converts all empty fields to nil when reading csv file
    CSV::Converters[:blank_to_nil] = lambda do |field|
      field && field.empty? ? nil : field
    end

    # Read a CSV file into an array of hashes with the symbolized headers as keys
    # Column separator is a colon.
    def read_csv( path )
      File.open(path) do |f|
        csv = CSV.new(f, :col_sep => ';', :headers => true, :header_converters => :symbol, :converters => [:all])
        csv.to_a.map {|row| row.to_hash }
      end
    end
    
    # Do we need to start a new file? (true/false)
    # tx = hash with csv values
    # customer = active customer identified by name
    def new_interchange?( tx, customer )
      if tx[:interchgstart] || ( tx[:customername] != customer )
        return true
      end
      false
    end
    
    # Do we need to start a new instruction? (true/false)
    # tx = hash with csv values
    # account = active account identified by IBAN
    def new_instruction?( tx, account )
      if tx[:instrstart] || ( tx[:customeriban] != account )
        return true
      end
      false
    end
    
    # Compute amount and return BigDecimal
    # Optionally inject symbol for relevant amount column
    def compute_amount( tx, dt, amnt=:amount )
    	amount = BigDecimal.new("0.00")
      # take given value if any
      if tx[amnt]
      	# Convert amount to string else it may be interpreted as a Rational
      	tmpno = tx[amnt].to_s
      	# Convert to american format if in german, i.e. swap usage of . and , 
      	if tmpno =~ /,[0-9]+$/
      		tmpno = tmpno.gsub(/\./, '').gsub(/,/, '.')
      	else
      		tmpno = tmpno.gsub(/,/, '')
      	end
        amount = BigDecimal.new(tmpno)
        tx[amnt] = amount.to_s("F") # Format output as string
      else # compute value according to actual day and index
        amount = BigDecimal.new("0.01") * BigDecimal.new(dt.day)  # decimal part according to day of date
        if tx[:amountspecial]
          amount = amount + BigDecimal.new(tx[:amountspecial])
        end
        if tx[:nr]
	        amount = amount + BigDecimal.new(tx[:nr]) # plus running index
	      end
        tx[amnt] = amount.to_s("F") # Format output as string
      end
      amount # Return BigDecimal for further computing
    end
    
    # Check for user defined values, either specific value or "empty"
    # Return computed value or default value if no user data available
    # tx : hash with csv data
    # default_value : must be returned if no user data specified
    # user_field : symbolized name of field with user data
    def derive_value( tx, default_value, user_field )
			usrdata = tx[user_field] 
			pval = usrdata ? usrdata : default_value # overwrite with user value
			pval = nil if usrdata == "empty" # nil if wanted
      return pval
    end
    
    # Create tag with field_value, "empty" generates empty tag,
    # missing field_value returns empty string.
    def create_tag( tag_name, field_value )
      return "" unless field_value
      if field_value == "empty"
        fv = nil
      else
        fv = field_value
      end
      return "<#{tag_name}>#{fv}</#{tag_name}>"
    end
    
    # Returns the default unless a user_value is given.
    # Caveat: A user_value of false or nil does not work!
    def check_default_value( default_value, user_value )
      return default_value unless user_value
      user_value
    end
    
    # Generate a file name according to TRAVIC conventions
    # based on the active interchange data row and a given job-id
    def compute_filename( customer_id, job_id ) 
      # Generate a virtual TRAVIC customer id (8 chars)
      travic_id = 'EXMT' + customer_id[0..4]
      # Generate a virtual 4 char TRAVIC order number
      travic_orderid = SecureRandom.hex(2).upcase
      "XXX.#{travic_id}.CCU.O.#{travic_orderid}.#{job_id}"
    end
    
    # Generate a time string to distinguish file names
    # Compare the input to the actual time: if input is in the future 
    # the result will be based on random data
    def get_jobid_time( target_date )
 	  	presenttime = Time.now
  	  # Either use given date or present time
    	if target_date <= presenttime
    		presenttime.strftime("%H%M%S")
    	else
    		"XX" + SecureRandom.hex(2).upcase
    	end
  	end
      
  end
  
end
