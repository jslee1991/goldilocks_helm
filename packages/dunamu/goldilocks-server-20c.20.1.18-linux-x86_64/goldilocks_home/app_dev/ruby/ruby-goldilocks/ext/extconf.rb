require 'mkmf'

WIN = RUBY_PLATFORM =~ /mswin/ || RUBY_PLATFORM =~ /mingw/

INCLUDE_DIR, LIB_DIR = dir_config("goldilocks")

if( (INCLUDE_DIR.nil?) || (LIB_DIR.nil?) ||
    (INCLUDE_DIR == '') || (LIB_DIR == '') )
  GOLDILOCKS_HOME = ENV['GOLDILOCKS_HOME']

  if( (GOLDILOCKS_HOME == nil) || (GOLDILOCKS_HOME == '') )
    puts "Environment variable GOLDILOCKS_HOME is not set. Set it to your GOLDILOCKS installation directory and retry gem install.\n "
    exit 1
  end
  GOLDILOCKS_INCLUDE, GOLDILOCKS_LIB = dir_config("goldilocks", GOLDILOCKS_HOME)
else
  GOLDILOCKS_INCLUDE = INCLUDE_DIR
  GOLDILOCKS_LIB = LIB_DIR
end

if( !(File.directory?(GOLDILOCKS_LIB)) )
  puts "Cannot find #{GOLDILOCKS_LIB} directory. Check if you have set the GOLDILOCKS_HOME environment variable's value correctly\n "
  exit 1
end

if( !(File.directory?(GOLDILOCKS_INCLUDE)) )
  puts " #{GOLDILOCKS_INCLUDE} folder not found. Check if you have set the GOLDILOCKS_HOME environment variable's value correctly\n "
  exit 1
end

GOLDILOCKS_LIBRARY = "gdlcs"

abort "-----\nCannot find goldilocks.h\n-----" unless have_header("goldilocks.h")
abort "-----\nCannot find " + (WIN ? '' : 'lib') + "#{GOLDILOCKS_LIBRARY}" + (WIN ? '.dll' : '.so') + "\n-----" unless have_library(GOLDILOCKS_LIBRARY)

create_makefile("goldilocks")
