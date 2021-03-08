#!/usr/bin/python

import unittest
import pygoldilocks
from optparse import OptionParser
import dbapi

def main():
    CNXN_STRING = 'DSN=GOLDILOCKS;uid=test;pwd=test;'
    parser = OptionParser( usage='usage: %prog [options] connection_string' )

    (options, args) = parser.parse_args()
    if len(args) > 1:
        parser.error('Only one argument is allowed.')

    if not args:
        connection_string=CNXN_STRING
    else:
        connection_string = args[0]

    class test_goldilocks( dbapi.DatabaseApiTest ):
        driver = pygoldilocks
        connect_args=[ connection_string ]
        connect_kw_args = {}

        #def test_nextset(self): pass
        # def test_setoutputsize(self): pass
        # def test_ExceptionAsConnectionAttributes(self): pass
    
    suite = unittest.makeSuite( test_pygoldilocks, 'test' )
    testRunner = unittest.TextTestRunner()
    result = testRunner.run( suite )
    
if __name__ == '__main__':
    main()
