# encoding: utf-8
require_relative 'my_functions.rb'
# load "init" configuration
require_relative 'configuration.rb'

#
# Tasks
#
# today        - Execution date is today
# tomorrow     - Execution date is tomorrow
#
define Task: "today" do
  config :today
  task :process
end

define Config: "today" do
  # Get time for execution date
  @today = shift_date(Time.now, 0)
end

define Task: "tomorrow" do
  config :tomorrow
  task :process
end

define Config: "tomorrow" do
  # Get time for execution date
  @today = shift_date(Time.now, 1)
end

#
# Processing definitions
#
define Task: :process do
  config :init
  @log.info { "Execution date will be #{@today}" }
  # variable for ID generation (16 characters)
  @id_timestamp = @today.strftime("D%Y%m%dT%H%M%S")

  inst_array = read_csv(@input_file)
  # first run to compute sums and tag scope changes
  inst_array.each do |tx|
    if tx[@inclusion]
      if new_interchange?(tx, @active_customer)
        @log.info "-- Start new interchange --"
        # Remember this transaction for collecting interchange data
        @active_interchange = tx
        tx[:hdrtxs] = 0
        tx[:hdrsum] = BigDecimal.new("0.00")
        tx[:interchgstart] = true
        # if we start a new interchange we will have a new instruction, too.
        tx[:instrstart] = true 
        # Customer for detection of automatic start of new interchange
        @active_customer = tx[:customername]
      end
      if new_instruction?(tx, @active_account)
        @log.info "-- Start new instruction --"
        # Remember this transaction for collecting instruction data
        tx[:instrstart] = true
        @active_instruction = tx
        tx[:pmttxs] = 0
        tx[:pmtsum] = BigDecimal.new("0.00")
        # Account for detection of automatic start of new instruction
        @active_account = tx[:customeriban]
      end
      # Checking number of copies to be at least 1
      tx[:copies] = 1 unless tx[:copies]
      @log.debug " ...now processing " + tx.inspect
      # Sum the amounts of all transactions
      copies = tx[:copies]
      copies.times do |loop|
        # amount will be given as BigDecimal, take care when processing.
        # Data in hash must be formatted as string for proper inclusion in template
        amount = compute_amount(tx, @today)
        @active_instruction[:pmttxs] += 1
        pmtsum = BigDecimal.new(@active_instruction[:pmtsum]) + amount
        @active_instruction[:pmtsum] = pmtsum.to_s("F") 
        @active_interchange[:hdrtxs] += 1
        hdrsum = BigDecimal.new(@active_interchange[:hdrsum]) + amount
        @active_interchange[:hdrsum] = hdrsum.to_s("F")
        @log.debug { "Interchange ##{@active_interchange[:nr]} = #{@active_interchange[:hdrsum]} (#{loop})" }
        @log.debug { "Instruction #" + "#{@active_instruction[:nr]} = #{@active_instruction[:hdrsum]} (#{loop})" }
      end
    end
  end
  @file_written = true
  # second run to generate output
  inst_array.each do |tx|
    if tx[@inclusion]
		  # variable for ID generation (4 digits)
		  @id_testdataid = tx[:nr].to_s.rjust(4,"0")

      @data = tx
      # create variables for ID generation
      if tx[:interchgstart]
			  # generate 10 digit job id for file names, based on execution date (yymmdd) and time (HHMM)
			  @jobid_time = get_jobid_time(@today)
			  @travic_jobid = @today.strftime("%m%d") + @jobid_time
        if @file_written == false
          template :instruction_footer
          template :interchange_footer
          write_file("./output/" + @active_filename)
          @file_written = true
        end
        template :interchange_header
        template :groupheader
        template :instruction_header
      	task :transaction_loop
        @file_written = false
        # generate filename in output directory
        @active_filename = compute_filename(@id_testdataid, @travic_jobid)
      elsif tx[:instrstart]
        template :instruction_footer
        template :instruction_header
      	task :transaction_loop
      else
      	task :transaction_loop
      end
    end
  end
  # close open interchange
  template :instruction_footer
  template :interchange_footer
  write_file("./output/" + @active_filename)  
end

define Task: :transaction_loop do
	# we are expecting variable @data to contain testdata information
  copies = @data[:copies]
  copies.times do |loop|
	  # variable for ID generation (6 characters)
	  @id_loop = "L" + loop.to_s.rjust(5,"0")
    @loop = loop
    # Generate a unique suffix (5 characters) to distinguish several transactions in a instruction
    @id_suffix = "S" + SecureRandom.hex(2).upcase
    template :transaction
  end
end
