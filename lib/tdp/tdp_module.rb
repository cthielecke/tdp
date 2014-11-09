# encoding: utf-8
module TDP

  # TDP module singleton methods.
  #
  class << self
    # Current TDP Application
    def application
      @application ||= TDP::Application.new
    end

    # Return the original directory where the TDP application was started.
    def original_dir
      application.original_dir
    end

    # Load a tdpfile.
    def load_tdp_file(path)
      load(path)
    end

    def load_template(file_name, paths=application.options.templates )
      fn = file_name.to_s + ".erubis"
      paths.each do |path|
        full_path = File.join(path, fn)
        if File.exist?(full_path)
          return File.read(full_path)
        end
      end
      fail LoadError, "Can't find template '#{file_name}' in #{paths}"
    end

  end
end
