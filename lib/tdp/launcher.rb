# encoding: utf-8
require_relative 'application'

module TDP

  class Launcher
  
    def read_testfile(filename)
      s = File.read(filename)
      if filename =~ /\.rb$/
        s =~ /^__END__$/ or raise "*** error: __END__ is not found in '#{filename}'."
        s = $'
      end
      return s
    end
  
  end

  class << self

    # Load a tdpfile.
    def load_tdp_file(path)
      l = TDP::Launcher.new
      eval(l.read_testfile(__FILE__))
    end
  
  end
    
end

TDP.application.run
exit(true)

__END__

define Task: "t1" do
  3.downto 1 do |i|
    template :tplx do
      @loop = i * @var
    end
  end
  config :footer
  template :footer
end
define Task: :t2 do
  template :start
end
define Procedure: "p1" do
  task :t2
  task :t1 do
    @var = 5
  end
end
define Task: :t3 do
  @var = 'y'
  @vart1 = true
  puts "@var = #{@var} in block #{name}"
  puts "Task #{name} called by #{parent.name}"
  template :tpl1 do
    @tplvar1 = "Dummy"
    puts "nothing to define for template #{name} called by #{parent.name}"
    puts "Instance variables in #{name} are #{instance_variables} !"
  end
  puts "Instance variables in #{name} are #{instance_variables} !"
end
define Task: :t4 do
  @loop ||= 99
  puts "Task #{name} called by #{parent.name}"
  puts "Loop #{@loop + 1} in block #{name}"
  puts "Instance variables in #{name} are #{instance_variables} !"
  template :tpl2 do
    @tplvarx = 99999
    puts "nothing to define for template #{name} called by #{parent.name}"
    puts "Instance variables in #{name} are #{instance_variables} !"
  end
end

define Procedure: :p3 do
  @var = 'x'
  task :t3
  puts "@var = #{@var} after :t3"
  puts "Instance variables in #{name} are #{instance_variables} !"
  2.times do |i|
    task :t4 do
      @loop = i
    end
    puts "@var = #{@var} after :t4"
  end
  task :t4 do
    config :cfg1
    template :tpl1
  end
end

define Config: :cfg1 do
  @config_var1 = "test1"
  @config_var2 = "test2"
  @config_var1 = "test3"
end

define Template: :tpl1 do
%{jhgf sduzgf sukdzg sudgf uzsdg fsuz hu  i  uzwg efuzgw uzwg uwegz uwgz uwgz fw8zegf w8ezgf w8e7gf 47z8374 8o7fo873g4o 873g }
end
