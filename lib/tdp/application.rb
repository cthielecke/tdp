# encoding: utf-8
require 'optparse'
require 'ostruct'
require 'rbconfig'

require_relative 'tdp_module'
require_relative 'keywords'
require_relative 'libraries'
require_relative 'version'
require_relative 'tdp_dsl'
require_relative 'default_loader'
require_relative 'engine'

module TDP

  ######################################################################
  # TDP main application object.  When invoking +tdp+ from the
  # command line, a TDP::Application object is created and run.
  #
  class Application

    # The name of the application (typically 'tdp')
    attr_reader :name

    # The original directory where tdp was invoked.
    attr_reader :original_dir

    # Name of the actual tdp_file used.
    attr_reader :tdp_file

    # List of the top level task names (task names from the command line).
    attr_reader :top_level_tasks

    DEFAULT_TDP_FILES = ['tdp_file.rb', 'TDP_file.rb', 'tdp_file.tdp', 'TDP_file.tdp'].freeze

    # Initialize a TDP::Application object.
    def initialize
      #super
      @name = 'tdp'
      @tdp_files = DEFAULT_TDP_FILES.dup
      @tdp_file = nil
      @original_dir = Dir.pwd
      @top_level_tasks = []
      @pending_imports = []
      @imported = []
      @loaders = {}
      @default_loader = TDP::DefaultLoader.new
      add_loader('rb', DefaultLoader.new)
      add_loader('tdp', DefaultLoader.new)
    end

    # Run the TDP application.  The run method performs the following
    # three steps:
    #
    # * Initialize the command line options (+init+).
    # * Define the actions (+load_tdp_file+).
    # * Run the top level tasks (+run_tasks+).
    #
    # If you wish to build a custom tdp command, you should call
    # +init+ on your application.  Then define any tasks.  Finally,
    # call +top_level+ to run your top level tasks.
    def run
      standard_exception_handling do
        init
        load_tdp_file
        top_level
      end
    end

    # Initialize the command line parameters and app name.
    def init(app_name='tdp')
      standard_exception_handling do
        @name = app_name
        handle_options
        collect_tasks
      end
    end

    # Find the tdp_file and then load it.
    def load_tdp_file
      standard_exception_handling do
        raw_load_tdp_file
      end
    end

    # Run the top level tasks of a TDP application.
    def top_level
      standard_exception_handling do
        top_level_tasks.each { |task_name| invoke_task(task_name) }
      end
    end

    # Add a loader to handle imported files ending in the extension
    # +ext+.
    def add_loader(ext, loader)
      ext = ".#{ext}" unless ext =~ /^\./
      @loaders[ext] = loader
    end

    # Application options from the command line
    def options
      @options ||= OpenStruct.new
    end

    # private ----------------------------------------------------------------

    def invoke_task(task_name)
      library_handler[:Task].get(task_name.to_sym).generate
    end

    # Provide standard exception handling for the given block.
    def standard_exception_handling
      begin
        yield
      rescue SystemExit => ex
        # Exit silently with current status
        raise
      rescue OptionParser::InvalidOption => ex
        $stderr.puts ex.message
        exit(false)
      rescue Exception => ex
        # Exit with error message
        display_error_message(ex)
        exit(false)
      end
    end

    # Display the error message that caused the exception.
    def display_error_message(ex)
      $stderr.puts "#{name} aborted!"
      $stderr.puts ex.message
      if options.trace
        $stderr.puts ex.backtrace.join("\n")
      else
        $stderr.puts tdp_file_location(ex.backtrace)
      end
      $stderr.puts "(See full trace by running task with --trace)" unless options.trace
    end

    # Warn about deprecated usage.
    #
    # Example:
    #    TDP.application.deprecate("import", "TDP.import", caller.first)
    #
    def deprecate(old_usage, new_usage, call_site)
      return if options.ignore_deprecate
      $stderr.puts "WARNING: '#{old_usage}' is deprecated.  " +
        "Please use '#{new_usage}' instead.\n" +
        "    at #{call_site}"
    end

    # True if one of the files in TDP_FILES is in the current directory.
    # If a match is found, it is copied into @tdp_file.
    def have_tdp_file
      @tdp_files.each do |fn|
        if File.exist?(fn)
          others = Dir.glob(fn, File::FNM_CASEFOLD)
          return others.size == 1 ? others.first : fn
        elsif fn == ''
          return fn
        end
      end
      return nil
    end

    # A list of all the standard options used in tdp, suitable for
    # passing to OptionParser.
    def standard_tdp_options
      [
        ['--dry-run', '-n', "Do a dry run without executing actions.",
          lambda { |value|
            options.dryrun = true
            options.trace = true
          }
        ],
        ['--libdir', '-I LIBDIR', "Include LIBDIR in the search path for required modules.",
          lambda { |value| $:.push(value) }
        ],
        ['--no-search', '--nosearch', '-N', "Do not search parent directories for the TDPfile.",
          lambda { |value| options.nosearch = true }
        ],
        ['--tdpfile', '-f [FILE]', "Use FILE as the TDPfile.",
          lambda { |value|
            value ||= ''
            @tdp_files.clear
            @tdp_files << value
          }
        ],
        ['--tdplib', '-L [TDPLIBDIR]',
          "Auto-import any .tdp files in TDPLIBDIR. (default is 'tdplib')",
          lambda { |value| 
            value ||= 'tdplib'
            options.tdplib = value.split("#{File::PATH_SEPARATOR}")
          }
        ],
        ['--templates', '-T [TEMPLATESDIR]',
          "Lookup template files in TEMPLATESDIR. (default is 'templates'),
           overrides any path statements in the TDPfile",
          lambda { |value| 
            value ||= 'templates'
            # freeze array to prevent additions from TDPfile
            puts "templates value = #{value}"
            add_template_path(files: value.split("#{File::PATH_SEPARATOR}"), freeze: true)
          }
        ],
        ['--trace', '-t', "Turn on invoke/execute tracing, enable full backtrace.",
          lambda { |value|
            options.trace = true
          }
        ],
        ['--version', '-V', "Display the program version.",
          lambda { |value|
            puts "tdp, version #{TDP::VERSION}"
            exit
          }
        ],
        ['--no-deprecation-warnings', '-X', "Disable the deprecation warnings.",
          lambda { |value|
            options.ignore_deprecate = true
          }
        ],
      ]
    end

    # Read and handle the command line options.
    def handle_options
      options.tdplib = ['tdplib']
      options.templates = []

      OptionParser.new do |opts|
        opts.banner = "tdp [-f tdp_file] {options} targets..."
        opts.separator ""
        opts.separator "Options are ..."

        opts.on_tail("-h", "--help", "-H", "Display this help message.") do
          puts opts
          exit
        end

        standard_tdp_options.each { |args| opts.on(*args) }
        opts.environment('TDPOPT')
      end.parse!
    end

    # Find first of files in TDP_FILES in current or upper directories.
    # If any file is found, file name and directory will be returned.
    def find_tdp_file_location
      here = Dir.pwd
      while ! (fn = have_tdp_file)
        Dir.chdir("..")
        if Dir.pwd == here || options.nosearch
          return nil
        end
        here = Dir.pwd
      end
      [fn, here]
    ensure
      Dir.chdir(TDP.original_dir)
    end

    def print_tdp_file_directory(location)
      $stderr.puts "(in #{Dir.pwd})" unless
        options.silent or original_dir == location
    end

    def raw_load_tdp_file # :nodoc:
      tdp_file, location = find_tdp_file_location
      fail "No TDPfile found (looking for: #{@tdp_files.join(', ')})" if
        tdp_file.nil?
      @tdp_file = tdp_file
      Dir.chdir(location)
      print_tdp_file_directory(location)
      TDP.load_tdp_file(File.expand_path(@tdp_file)) if @tdp_file && @tdp_file != ''
      options.tdplib.each do |tlib|
        glob("#{tlib}/*.tdp") do |name|
          add_import name
        end
      end     
      load_imports
    end

    def glob(path, &block)
      Dir[path.gsub("\\", '/')].each(&block)
    end
    private :glob

    # Collect the list of tasks on the command line.  If no tasks are
    # given, return a list containing only the default task.
    # Environmental assignments are processed at this time as well.
    def collect_tasks
      @top_level_tasks = []
      ARGV.each do |arg|
        if arg =~ /^(\w+)=(.*)$/
          ENV[$1] = $2
        else
          @top_level_tasks << arg unless arg =~ /^-/
        end
      end
      @top_level_tasks.push("default") if @top_level_tasks.size == 0
    end

    # Add a file to the list of files to be imported.
    def add_import(fn)
      @pending_imports << fn
    end

    # Load the pending list of imported files.
    def load_imports
      while fn = @pending_imports.shift
        next if @imported.member?(fn)
        ext = File.extname(fn)
        loader = @loaders[ext] || @default_loader
        loader.load(fn)
        @imported << fn
      end
    end

    # Warn about deprecated use of top level constant names.
    def const_warning(const_name)
      @const_warning ||= false
      if ! @const_warning
        $stderr.puts %{WARNING: Deprecated reference to top-level constant '#{const_name}' } +
          %{found at: #{tdp_file_location}} # '
        $stderr.puts %{    Use --classic-namespace on tdp command}
        $stderr.puts %{    or 'require "tdp/classic_namespace"' in TDPfile}
      end
      @const_warning = true
    end

    def tdp_file_location backtrace = caller
      backtrace.map { |t| t[/([^:]+):/,1] }

      re = /^#{@tdp_file}$/
      re = /#{re.source}/i if windows?

      backtrace.find { |str| str =~ re } || ''
    end
    
    def unix?
      RbConfig::CONFIG['host_os'] =~ /(aix|darwin|linux|(net|free|open)bsd|cygwin|solaris|irix|hpux)/i
    end

    def windows?
      RbConfig::CONFIG["host_os"] =~  %r!(msdos|mswin|djgpp|mingw|[Ww]indows)!
    end
  
    # Get or initialize a list of libraries, provided through a library handler
    def library_handler
      @library_handler  ||= TDP::LibraryHandler.new(:Task, :Template, :Config)
    end
    
    # Check whether a library for a certain class has been defined for the application
    def library_defined?( klass )
      library_handler.defined?(klass)
    end
 
    # add item to library according to class 
    #
    def add_item( klass, name, action )
      fail SyntaxError, "Undefined class #{klass} found in #{self}" unless library_defined?(klass)
      library_handler[klass].define(name, action) 
    end
    
    # Add directories to lookup path for templates if the option isn't frozen.
    # Command line option will freeze the list.
    def add_template_path( args )
      files = args[:files]
      if !(options.templates.frozen?)
        files.each do |fn|
          options.templates << File.expand_path(fn)
        end
      end
      if args[:freeze] == true
        options.templates.freeze
      end
    end
    
  end
end
