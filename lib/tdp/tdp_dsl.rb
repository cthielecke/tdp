# encoding: utf-8

module TDP

  # Define top level keywords for tdp files
  module DSL
    
    # Define a new task, configuration or template
    #
    # Example:
    #  define Task: :name do
    #    ...some ruby code
    #  end
    #
    def define( hsh, &action )
      raise ArgumentError, "Class and name not given" if hsh.nil?
      raise ArgumentError, "Action not given" if action.nil?
      klass = hsh.keys[0]
      name = hsh[klass]
      TDP.application.add_item(klass, name, action)
    end
    
    # Import the partial tdp files +fn+.  Imported files are loaded
    # _after_ the current file is completely loaded. 
    #
    # See also the --tdplib command line option.
    #
    # Example:
    #   import "configurations.tdp", "my_tasks.tdp"
    #
    def import(*fns)
      fns.each do |fn|
        TDP.application.add_import(fn)
      end
    end
    
    # Define path for template file lookup. Add given directories to path.
    # You may override this statement with the command line option "-T"
    #
    # Example:
    #   template_path "./templates", "C:/users/theo/erubis"
    #
    def template_path( *fns )
      TDP.application.add_template_path(files: fns, freeze: false)
    end
    
  end

end

# Make keywords known to top level Object
#
self.extend TDP::DSL