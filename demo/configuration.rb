# encoding: utf-8
require_relative 'my_functions.rb'

template_path "./templates"

define Config: "init" do
  # Create a logger to STDOUT, just for dev issues
  @log = Logger.new(STDOUT)
  @log.level = Logger::INFO # options are ERROR, WARN, INFO or DEBUG

	# Take the name of the input file from the environment
	# otherwise use a default
	@input_file = ENV['paymentinfo_file']
	@input_file ||= "paymentinfo.csv"

	# Take the id for the test environment, test focus etc. from the environment
	# eg. "EE" (E2E), "ST" (Systemtest), "LP" (L&P)
	# otherwise use a default
	@id_env = ENV['id_env']
	@id_env ||= "ID"

	# Specify column name that controls inclusion of lines
	@inclusion = :generate
	
  # set initial internal variable values
  # do not change this config below this line
  @active_account = 'dummy'
  @active_customer = 'dummy'
  @active_interchange = nil
  @active_instruction = nil
end

