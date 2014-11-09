module TDP

  # Default tdp file loader used by +import+.
  class DefaultLoader
    def load(fn)
      TDP.load_tdp_file(File.expand_path(fn))
    end
  end

end
