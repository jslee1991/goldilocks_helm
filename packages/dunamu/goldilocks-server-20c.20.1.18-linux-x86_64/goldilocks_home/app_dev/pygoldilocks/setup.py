import os
import sys
import platform
import traceback

try:
    from setuptools import setup, Extension
except ImportError:
    from distutils.core import setup
    from distutils.extension import Extension
from distutils import sysconfig

product_name = 'pygoldilocks'
product_version = '20.1.18'

long_description = 'A Python DB API 2 module for Goldilocks ODBC.'

classifiers = [
    'Development Status :: 1 - alpha',
    'License :: MIT License',
    'Operating System :: POSIX',
    'Programming Language :: C',
    'Programming Language :: Python',
    'Programming Language :: Python :: 2',
    'Programming Language :: Python :: 2.7',
    'Programming Language :: Python :: 3',
    'Programming Language :: Python :: 3.4',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: Python :: 3.6',
    'Topic :: Database',
]

try:
    product_home = os.environ[ "GOLDILOCKS_HOME" ]
except KeyError:
    print("Please set the environment variable GOLDILOCKS_HOME")

product_lib  = os.path.join( product_home, 'lib' )
product_inc  = os.path.join( product_home, 'include' )

def get_compile_settings():
    bit = platform.architecture()

    settings = []

    if sys.platform == 'win32':
        settings.extend( [ '/MP','-D_CRT_SECURE_NO_DEPRECATE', '/wd4005', '/wd4013', '/wd4018', '/wd4090', '/wd4098', '/wd4100', '/wd4114', '/wd4115','/wd4127', '/wd4191', '/wd4200', '/wd4201', '/wd4206', '/wd4242', '/wd4244', '/wd4255', '/wd4267', '/wd4296', '/wd4306', '/wd4388', '/wd4389', '/wd4514', '/wd4548', '/wd4668', '/wd4702', '/wd4710', '/wd4711', '/wd4756', '/wd4819', '/wd4820', '/wd4996' ] )
    elif sys.platform == 'darwin': 
        settings.extend( [ '-Wno-strict-prototypes', '-D_GNU_SOURCE', '-std=gnu99', '-D_XOPEN_SOURCE=700' ] )
        if '64' in bit[0]:
            settings.append( '-m64' )
        else:
            settings.append( '-m32' )
    elif sys.platform == 'hp-ux11':
        settings.extend( [ '-Wno-strict-prototypes', 'D_PSTAT64', '-D_REENTRANT', '-O2' ] )
        if '64' in bit[0]:
            settings.append( '-mlp64' )
        else:
            settings.append( '-milp32' )
    else:
        settings.extend( [ '-Wno-strict-prototypes', '-D_GNU_SOURCE', '-std=gnu99', '-D_XOPNE_SOURCE=700', '-O2' ] )
        if '64' in bit[0]:
            settings.append( '-m64' )
        else:
            settings.append( '-m32' )
    
    settings.append( '-Wall' )

    return settings

def get_dir_list( aPath ):
    sDirs = []
    if os.path.exists( aPath ):
        for sDir in os.listdir( aPath ):
            if sDir.startswith( 'python' ):
                sDirs.append( os.path.abspath( os.path.join( aPath, sDir ) ) )
            elif sDir.startswith( 'Python' ):
                sDirs.append( os.path.abspath( os.path.join( aPath, sDir ) ) )
    return sDirs

def get_include_dirs():
    sSettings = [ os.path.abspath( 'src' ), product_inc ] 

    if sys.platform == 'linux2' or sys.platform == 'linux':
        sSettings.extend( get_dir_list( '/opt/at6.0/include/' ) )

    return sSettings

def get_lib_dirs():
    sSettings = [ product_lib ]

    if sys.platform == 'linux2' or sys.platform == 'linux':
        if os.path.exists( '/opt/at6.0/lib64/' ):
            sSettings.extend( ['/opt/at6.0/lib64/'] )
        if os.path.exists( '/opt/at6.0/lib/' ):
            sSettings.extend( ['/opt/at6.0/lib/'] )

    return sSettings

def get_db_library():
    return 'gdlcs'

def main():
    src = [ os.path.relpath( os.path.join('src', file) ) for file in os.listdir('src') if file.endswith('.c') ]

    compile_args = get_compile_settings()
    include_dirs = get_include_dirs()
    lib_dirs = get_lib_dirs()
    db_lib   = get_db_library()

    ext_mod = [ Extension( name = product_name,
                           include_dirs = include_dirs,
                           define_macros = [('PYGOLDILOCKS_VERSION', product_version)],
                           extra_compile_args = compile_args,
                           sources = src,
                           libraries = [db_lib],
                           library_dirs = lib_dirs
    ) ]

    try:
        opts = sysconfig.get_config_vars( 'OPT' )
        sysconfig._config_vars['OPT'] = opts[0].replace( ' -g ', ' ' )
    
        configure_cflags = sysconfig.get_config_vars( 'CONFIGURE_CFLAGS' )
        sysconfig._config_vars['CONFIGURE_CFLAGS'] = configure_cflags[0].replace( ' -g ', ' ' )
    except AttributeError:
        pass
    
    setup( name             = product_name,
           version          = product_version,
           description      = 'Python interface to Goldilocks',
           long_description = long_description,
           author           = 'lkh',
           author_email     = 'lkh@sunesoft.com',
           ext_modules      = ext_mod,
           classifiers      = classifiers )

if __name__ == '__main__':
    main()
