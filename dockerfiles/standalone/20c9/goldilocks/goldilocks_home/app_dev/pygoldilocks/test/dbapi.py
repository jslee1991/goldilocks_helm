#!/usr/bin/env python

import unittest
import time

class DatabaseApiTest( unittest.TestCase ):
    driver = None
    connect_args=()
    connect_kw_args={}
    table_prefix = 'dbapitest_'
    
    ddl1 = 'create table %sbooze (name varchar(20))' % table_prefix
    ddl1_d = 'drop table if exists %sbooze' % table_prefix
    ddl2 = 'create table %sbarflys (name varchar(20))' % table_prefix
    ddl2_d = 'drop table if exists %sbarflys' % table_prefix
    
    def _connect( self ):
        try:
            return self.driver.connect( *self.connect_args, **self.connect_kw_args )
        except AttributeError:
            self.fail("No connect method found in self.driver module")

    def setUp(self):
        pass

    def tearDown(self):
        con = self._connect()

        try:
            cur = con.cursor()
            for i, ddl in enumerate( () ):
                try:
                    cur.execute(ddl)
                    con.commit()
                except self.driver.Error:
                    pass
        finally:
            con.close()

    def executeDDL1(self,cursor):
        cursor.execute(self.ddl1_d)
        cursor.execute(self.ddl1)
        
    def executeDDL2(self,cursor):
        cursor.execute(self.ddl2_d)
        cursor.execute(self.ddl2)

    def test_connect(self):
        con = self._connect()
        con.close()

    def test_apilevel(self):
        try:
            apilevel = self.driver.apilevel
            self.assertEqual(apilevel, '2.0')
        except AttributeError:
            self.fail("Driver does not define apilevel")

    def test_threadsafety(self):
        try:
            threadsafety = self.driver.threadsafety
            self.failUnless(threadsafety in (0,1,2,3))
        except AttributeError:
            self.fail("Driver does not define threadsafety")

    def test_paramstyle(self):
        try:
            paramstyle = self.driver.paramstyle
            self.failUnless(paramstyle in ('qmark', 'numeric', 'named', 'format', 'pyformat'))
        except AttributeError:
            self.fail("Driver does not define paramstyle")

    def test_Exceptions(self):
        self.failUnless(issubclass(self.driver.Warning, StandardError))
        self.failUnless(issubclass(self.driver.Error, StandardError))
        self.failUnless(issubclass(self.driver.InterfaceError, self.driver.Error))
        self.failUnless(issubclass(self.driver.DatabaseError, self.driver.Error))
        self.failUnless(issubclass(self.driver.OperationalError, self.driver.Error))
        self.failUnless(issubclass(self.driver.IntegrityError, self.driver.Error))
        self.failUnless(issubclass(self.driver.InternalError, self.driver.Error))
        self.failUnless(issubclass(self.driver.ProgrammingError, self.driver.Error))
        self.failUnless(issubclass(self.driver.NotSupportedError, self.driver.Error))

    def test_commit(self):
        con = self._connect()
        try:
            con.commit()
        finally:
            con.close()

    def test_rollback(self):
        con = self._connect()
        if hasattr(con,'rollback'):
            try:
                con.rollback()
            except self.driver.NotSupportedError:
                pass
    
    def test_cursor(self):
        con = self._connect()
        try:
            cur = con.cursor()
        finally:
            con.close()
            
    def test_cursor_isolation(self):
        con = self._connect()
        try:
            # Make sure cursors created from the same connection have
            # the documented transaction isolation level
            cur1 = con.cursor()
            cur2 = con.cursor()
            self.executeDDL1(cur1)
            cur1.execute("insert into %sbooze values ('Isolation test')" % (self.table_prefix))
            cur2.execute("select name from %sbooze" % self.table_prefix)
            booze = cur2.fetchall()
            self.assertEqual(len(booze),1)
            self.assertEqual(len(booze[0]),1)
            self.assertEqual(booze[0][0],'Isolation test')
        finally:
            con.close()

    def test_description(self):
        con = self._connect()
        try:
            cur = con.cursor()
            self.executeDDL1(cur)
            self.assertEqual(cur.description, None,
                'cursor.description should be none after executing a '
                'statement that can return no rows (such as DDL)')
            
            cur.execute('select name from %sbooze' % self.table_prefix)
            self.assertEqual(len(cur.description),1,
                'cursor.description describes too many columns')
            self.assertEqual(len(cur.description[0]),7,
                'cursor.description[x] tuples must have 7 elements')
            self.assertEqual(cur.description[0][0].lower(),'name',
                'cursor.description[x][0] must return column name')
            self.assertEqual(cur.description[0][1],self.driver.STRING,
                'cursor.description[x][1] must return column type. Got %r'
                    % cur.description[0][1])

            # Make sure self.description gets reset
            self.executeDDL2(cur)
            self.assertEqual(cur.description,None,
                'cursor.description not being set to None when executing '
                'no-result statements (eg. DDL)')
        finally:
            con.close()

    def test_rowcount(self):
        con = self._connect()
        try:
            cur = con.cursor()
            self.executeDDL1(cur)
            self.assertEqual(cur.rowcount,-1,
                             'cursor.rowcount should be -1 after executing no-result '
                             'statements')
            cur.execute("insert into %sbooze values ('Victoria Bitter')" % (
                self.table_prefix))
            self.failUnless(cur.rowcount in (-1,1),
                            'cursor.rowcount should == number or rows inserted, or '
                            'set to -1 after executing an insert statement')
            cur.execute("select name from %sbooze" % self.table_prefix)
            self.failUnless(cur.rowcount in (-1,1),
                            'cursor.rowcount should == number of rows returned, or '
                            'set to -1 after executing a select statement')
            self.executeDDL2(cur)
            self.assertEqual(cur.rowcount,-1,
                             'cursor.rowcount not being reset to -1 after executing '
                             'no-result statements')
        finally:
            con.close()

    lower_func = 'lower'
    def test_callproc(self):
        con = self._connect()
        try:
            cur = con.cursor()
            if self.lower_func and hasattr(cur,'callproc'):
                r = cur.callproc(self.lower_func,('FOO',))
                self.assertEqual(len(r),1)
                self.assertEqual(r[0],'FOO')
                r = cur.fetchall()
                self.assertEqual(len(r),
                                 1,
                                 'callproc produced no result set')
                self.assertEqual(len(r[0]),
                                 1,
                                 'callproc produced invalid result set')
                self.assertEqual(r[0][0],
                                 'foo',
                                 'callproc produced invalid results')
        finally:
            con.close()

    def test_close(self):
        con = self._connect()
        try:
            cur = con.cursor()
        finally:
            con.close()

        # cursor.execute should raise an Error if called after connection
        # closed
        self.assertRaises( self.driver.Error,
                           self.executeDDL1,
                           cur)
        # connection.commit should raise an Error if called after connection'
        # closed.'
        self.assertRaises(self.driver.Error,con.commit)

        # connection.close should raise an Error if called more than once
        self.assertRaises(self.driver.Error,con.close)

    def test_execute(self):
        con = self._connect()
        try:
            cur = con.cursor()
            self._paraminsert(cur)
        finally:
            con.close()

    def _paraminsert(self,cur):
        self.executeDDL1(cur)
        cur.execute("insert into %sbooze values ('Victoria Bitter')" % (
            self.table_prefix ))
        self.failUnless(cur.rowcount in (-1,1))

        if self.driver.paramstyle == 'qmark':
            cur.execute('insert into %sbooze values (?)' % self.table_prefix,
                        ("Cooper's",))
        elif self.driver.paramstyle == 'numeric':
            cur.execute( 'insert into %sbooze values (:1)' % self.table_prefix,
                         ("Cooper's",))
        elif self.driver.paramstyle == 'named':
            cur.execute( 'insert into %sbooze values (:beer)' % self.table_prefix, 
                         {'beer':"Cooper's"})
        elif self.driver.paramstyle == 'format':
            cur.execute( 'insert into %sbooze values (%%s)' % self.table_prefix,
                         ("Cooper's",) )
        elif self.driver.paramstyle == 'pyformat':
            cur.execute('insert into %sbooze values (%%(beer)s)' % self.table_prefix,
                        {'beer':"Cooper's"} )
        else:
            self.fail('Invalid paramstyle')

        self.failUnless(cur.rowcount in (-1,1))

        cur.execute('select name from %sbooze' % self.table_prefix)
        res = cur.fetchall()
        self.assertEqual(len(res),2,'cursor.fetchall returned too few rows')
        beers = [res[0][0],res[1][0]]
        beers.sort()
        self.assertEqual(beers[0],
                         "Cooper's",
                         'cursor.fetchall retrieved incorrect data, or data inserted '
                         'incorrectly')
        self.assertEqual(beers[1],
                         "Victoria Bitter",
                         'cursor.fetchall retrieved incorrect data, or data inserted '
                         'incorrectly')

    def test_executemany(self):
        con = self._connect()
        try:
            cur = con.cursor()
            self.executeDDL1(cur)
            largs = [ ("Cooper's",) , ("Boag's",) ]
            margs = [ {'beer': "Cooper's"}, {'beer': "Boag's"} ]
            if self.driver.paramstyle == 'qmark':
                cur.executemany('insert into %sbooze values (?)' % self.table_prefix,
                                largs )
            elif self.driver.paramstyle == 'numeric':
                cur.executemany('insert into %sbooze values (:1)' % self.table_prefix,
                                largs)
            elif self.driver.paramstyle == 'named':
                cur.executemany('insert into %sbooze values (:beer)' % self.table_prefix,
                                margs)
            elif self.driver.paramstyle == 'format':
                cur.executemany('insert into %sbooze values (%%s)' % self.table_prefix,
                                largs)
            elif self.driver.paramstyle == 'pyformat':
                cur.executemany('insert into %sbooze values (%%(beer)s)' % self.table_prefix,
                                margs)
            else:
                self.fail('Unknown paramstyle')
            self.failUnless(cur.rowcount in (-1,2),
                            'insert using cursor.executemany set cursor.rowcount to '
                            'incorrect value %r' % cur.rowcount)
            cur.execute('select name from %sbooze' % self.table_prefix)
            res = cur.fetchall()
            self.assertEqual(len(res),2,
                             'cursor.fetchall retrieved incorrect number of rows')
            beers = [res[0][0],res[1][0]]
            beers.sort()
            self.assertEqual(beers[0],"Boag's",'incorrect data retrieved')
            self.assertEqual(beers[1],"Cooper's",'incorrect data retrieved')
        finally:
            con.close()

    def test_fetchone(self):
        con = self._connect()
        try:
            cur = con.cursor()

            # cursor.fetchone should raise an Error if called before
            # executing a select-type query
            self.assertRaises(self.driver.Error,cur.fetchone)

            # cursor.fetchone should raise an Error if called after
            # executing a query that cannnot return rows
            self.executeDDL1(cur)
            self.assertRaises(self.driver.Error,cur.fetchone)

            cur.execute('select name from %sbooze' % self.table_prefix)
            self.assertEqual(cur.fetchone(),None,
                'cursor.fetchone should return None if a query retrieves '
                'no rows'
                )
            self.failUnless(cur.rowcount in (-1,0))

            # cursor.fetchone should raise an Error if called after
            # executing a query that cannnot return rows
            cur.execute("insert into %sbooze values ('Victoria Bitter')" % (
                self.table_prefix
                ))
            self.assertRaises(self.driver.Error,cur.fetchone)

            cur.execute('select name from %sbooze' % self.table_prefix)
            r = cur.fetchone()
            self.assertEqual(len(r),1,
                'cursor.fetchone should have retrieved a single row'
                )
            self.assertEqual(r[0],'Victoria Bitter',
                'cursor.fetchone retrieved incorrect data'
                )
            self.assertEqual(cur.fetchone(),None,
                'cursor.fetchone should return None if no more rows available'
                )
            self.failUnless(cur.rowcount in (-1,1))
        finally:
            con.close()

    samples = [
        'Carlton Cold',
        'Carlton Draft',
        'Mountain Goat',
        'Redback',
        'Victoria Bitter',
        'XXXX'
        ]

    def _populate(self):
        ''' Return a list of sql commands to setup the DB for the fetch
            tests.
        '''
        populate = [
            "insert into %sbooze values ('%s')" % (self.table_prefix,s) 
            for s in self.samples
            ]
        return populate

    def test_fetchmany(self):
        con = self._connect()
        try:
            cur = con.cursor()

            # cursor.fetchmany should raise an Error if called without
            #issuing a query
            self.assertRaises(self.driver.Error,cur.fetchmany,4)

            self.executeDDL1(cur)
            for sql in self._populate():
                cur.execute(sql)

            cur.execute('select name from %sbooze' % self.table_prefix)
            r = cur.fetchmany()
            self.assertEqual(len(r),1,
                'cursor.fetchmany retrieved incorrect number of rows, '
                'default of arraysize is one.'
                )
            cur.arraysize=10
            r = cur.fetchmany(3) # Should get 3 rows
            self.assertEqual(len(r),3,
                'cursor.fetchmany retrieved incorrect number of rows'
                )
            r = cur.fetchmany(4) # Should get 2 more
            self.assertEqual(len(r),2,
                'cursor.fetchmany retrieved incorrect number of rows'
                )
            r = cur.fetchmany(4) # Should be an empty sequence
            self.assertEqual(len(r),0,
                'cursor.fetchmany should return an empty sequence after '
                'results are exhausted'
            )
            self.failUnless(cur.rowcount in (-1,6))

            # Same as above, using cursor.arraysize
            cur.arraysize=4
            cur.execute('select name from %sbooze' % self.table_prefix)
            r = cur.fetchmany() # Should get 4 rows
            self.assertEqual(len(r),4,
                'cursor.arraysize not being honoured by fetchmany'
                )
            r = cur.fetchmany() # Should get 2 more
            self.assertEqual(len(r),2)
            r = cur.fetchmany() # Should be an empty sequence
            self.assertEqual(len(r),0)
            self.failUnless(cur.rowcount in (-1,6))

            cur.arraysize=6
            cur.execute('select name from %sbooze' % self.table_prefix)
            rows = cur.fetchmany() # Should get all rows
            self.failUnless(cur.rowcount in (-1,6))
            self.assertEqual(len(rows),6)
            self.assertEqual(len(rows),6)
            rows = [r[0] for r in rows]
            rows.sort()
          
            # Make sure we get the right data back out
            for i in range(0,6):
                self.assertEqual(rows[i],self.samples[i],
                    'incorrect data retrieved by cursor.fetchmany'
                    )

            rows = cur.fetchmany() # Should return an empty list
            self.assertEqual(len(rows),0,
                'cursor.fetchmany should return an empty sequence if '
                'called after the whole result set has been fetched'
                )
            self.failUnless(cur.rowcount in (-1,6))

            self.executeDDL2(cur)
            cur.execute('select name from %sbarflys' % self.table_prefix)
            r = cur.fetchmany() # Should get empty sequence
            self.assertEqual(len(r),0,
                'cursor.fetchmany should return an empty sequence if '
                'query retrieved no rows'
                )
            self.failUnless(cur.rowcount in (-1,0))

        finally:
            con.close()

    def test_fetchall(self):
        con = self._connect()
        try:
            cur = con.cursor()
            # cursor.fetchall should raise an Error if called
            # without executing a query that may return rows (such
            # as a select)
            self.assertRaises(self.driver.Error, cur.fetchall)

            self.executeDDL1(cur)
            for sql in self._populate():
                cur.execute(sql)

            # cursor.fetchall should raise an Error if called
            # after executing a a statement that cannot return rows
            self.assertRaises(self.driver.Error,cur.fetchall)

            cur.execute('select name from %sbooze' % self.table_prefix)
            rows = cur.fetchall()
            self.failUnless(cur.rowcount in (-1,len(self.samples)))
            self.assertEqual(len(rows),len(self.samples),
                'cursor.fetchall did not retrieve all rows'
                )
            rows = [r[0] for r in rows]
            rows.sort()
            for i in range(0,len(self.samples)):
                self.assertEqual(rows[i],self.samples[i],
                'cursor.fetchall retrieved incorrect rows'
                )
            rows = cur.fetchall()
            self.assertEqual(
                len(rows),0,
                'cursor.fetchall should return an empty list if called '
                'after the whole result set has been fetched'
                )
            self.failUnless(cur.rowcount in (-1,len(self.samples)))

            self.executeDDL2(cur)
            cur.execute('select name from %sbarflys' % self.table_prefix)
            rows = cur.fetchall()
            self.failUnless(cur.rowcount in (-1,0))
            self.assertEqual(len(rows),0,
                'cursor.fetchall should return an empty list if '
                'a select query returns no rows'
                )
            
        finally:
            con.close()
    
    def test_mixedfetch(self):
        con = self._connect()
        try:
            cur = con.cursor()
            self.executeDDL1(cur)
            for sql in self._populate():
                cur.execute(sql)

            cur.execute('select name from %sbooze' % self.table_prefix)
            rows1  = cur.fetchone()
            rows23 = cur.fetchmany(2)
            rows4  = cur.fetchone()
            rows56 = cur.fetchall()
            self.failUnless(cur.rowcount in (-1,6))
            self.assertEqual(len(rows23),2,
                'fetchmany returned incorrect number of rows'
                )
            self.assertEqual(len(rows56),2,
                'fetchall returned incorrect number of rows'
                )

            rows = [rows1[0]]
            rows.extend([rows23[0][0],rows23[1][0]])
            rows.append(rows4[0])
            rows.extend([rows56[0][0],rows56[1][0]])
            rows.sort()
            for i in range(0,len(self.samples)):
                self.assertEqual(rows[i],self.samples[i],
                    'incorrect data retrieved or inserted'
                    )
        finally:
            con.close()

    def create_procedure(self,cur):
        sql="""
           create or replace procedure proc1 ( a1 out integer )
           is
             v1 integer;
           begin
             select count(*) into v1 from %sbooze;
             a1 := v1;
           end;\
        """ % self.table_prefix
        cur.execute(sql)

    def delete_procedure(self,cur):
        'If cleaning up is needed after nextSetTest'
        cur.execute("drop procedure proc1")

    def create_function(self,cur):
        sql="""
           create or replace function func1 ( )
           return integer
           is
             v1 integer;
           begin
             select count(*) into v1 from %sbooze;
             return v1;
           end;\
        """ % self.table_prefix
        cur.execute(sql)

    def delete_function(self,cur):
        'If cleaning up is needed after nextSetTest'
        cur.execute("drop function func1")
        
    def test_callproc(self):
        con = self._connect()
        try:
            cur = con.cursor()

            try:
                self.executeDDL1(cur)
                sql=self._populate()
                for sql in self._populate():
                    cur.execute(sql)

                cur.commit()
                self.create_procedure(cur)

                r = cur.callproc('PROC1', (0, ))
                cur.execute( 'select * from %sbooze' % self.table_prefix )
                cnt = cur.fetchall()
                assert len(cnt) == r[0]
            finally:
                self.delete_procedure(cur)
        finally:
            con.close()

    def test_callfunc(self):
        con = self._connect()
        try:
            cur = con.cursor()

            try:
                self.executeDDL1(cur)
                sql=self._populate()
                for sql in self._populate():
                    cur.execute(sql)

                cur.commit()
                self.create_function(cur)

                r = cur.callfunc('FUNC1' )
                cur.execute( 'select * from %sbooze' % self.table_prefix )
                cnt = cur.fetchall()
                assert len(cnt) == r
            finally:
                self.delete_function(cur)
        finally:
            con.close()
    
    # def test_nextset(self):
    #     con = self._connect()
    #     try:
    #         cur = con.cursor()
    #         if not hasattr(cur,'nextset'):
    #             return

    #         try:
    #             self.executeDDL1(cur)
    #             sql=self._populate()
    #             for sql in self._populate():
    #                 cur.execute(sql)

    #             self.create_procedure(cur)

    #             cur.callproc('proc1', (0, ))
    #             # numberofrows=cur.fetchone()
    #             assert numberofrows[0]== len(self.samples)
    #             assert cur.nextset()
    #             names=cur.fetchall()
    #             assert len(names) == len(self.samples)
    #             s=cur.nextset()
    #             assert s == None,'No more return sets, should return None'
    #         finally:
    #             self.delete_procedure(cur)
    #     finally:
    #         con.close()

    # def test_nextset(self):
    #     raise NotImplementedError,'Drivers need to override this test'

    def test_arraysize(self):
        # Not much here - rest of the tests for this are in test_fetchmany
        con = self._connect()
        try:
            cur = con.cursor()
            self.failUnless(hasattr(cur,'arraysize'),
                            'cursor.arraysize must be defined' )
        finally:
            con.close()

    def test_setinputsizes(self):
        con = self._connect()
        try:
            cur = con.cursor()
            cur.setinputsizes( (25,) )
            self._paraminsert(cur) # Make sure cursor still works
        finally:
            con.close()

    def test_setoutputsize_basic(self):
        # Basic test is to make sure setoutputsize doesn't blow up
        con = self._connect()
        try:
            cur = con.cursor()
            cur.setoutputsize(1000)
            cur.setoutputsize(2000,0)
            self._paraminsert(cur) # Make sure the cursor still works
        finally:
            con.close()

    def test_setoutputsize(self):
        con = self._connect()
        try:
            cur = con.cursor()
            cur.setoutputsize( 10000 )
            
        finally:
            con.close()

    def test_None(self):
        con = self._connect()
        try:
            cur = con.cursor()
            self.executeDDL1(cur)
            cur.execute('insert into %sbooze values (NULL)' % self.table_prefix)
            cur.execute('select name from %sbooze' % self.table_prefix)
            r = cur.fetchall()
            self.assertEqual(len(r),1)
            self.assertEqual(len(r[0]),1)
            self.assertEqual(r[0][0],None,'NULL value not returned as None')
        finally:
            con.close()

    def test_Date(self):
        d1 = self.driver.Date(2002,12,25)
        d2 = self.driver.DateFromTicks(time.mktime((2002,12,25,0,0,0,0,0,0)))
        # Can we assume this? API doesn't specify, but it seems implied
        self.assertEqual(str(d1),str(d2))

    def test_Time(self):
        t1 = self.driver.Time(13,45,30)
        t2 = self.driver.TimeFromTicks(time.mktime((2001,1,1,13,45,30,0,0,0)))
        # Can we assume this? API doesn't specify, but it seems implied
        self.assertEqual(str(t1),str(t2))

    def test_Timestamp(self):
        t1 = self.driver.Timestamp(2002,12,25,13,45,30)
        t2 = self.driver.TimestampFromTicks( time.mktime((2002,12,25,13,45,30,0,0,0)) )
        # Can we assume this? API doesn't specify, but it seems implied
        self.assertEqual(str(t1),str(t2))

    def test_Binary(self):
        b = self.driver.Binary('Something')
        self.assertEqual( bytearray('Something'), b )
        b = self.driver.Binary('')
        self.assertEqual( bytearray(''), b )
        
    def test_STRING(self):
        self.failUnless(hasattr(self.driver,'STRING'),
                        'module.STRING must be defined')

    def test_BINARY(self):
        self.failUnless(hasattr(self.driver,'BINARY'),
                        'module.BINARY must be defined.')

    def test_NUMBER(self):
        self.failUnless(hasattr(self.driver,'NUMBER'),
                        'module.NUMBER must be defined.')

    def test_DATETIME(self):
        self.failUnless(hasattr(self.driver,'DATETIME'),
                        'module.DATETIME must be defined.')

    def test_ROWID(self):
        self.failUnless(hasattr(self.driver,'ROWID'),
                        'module.ROWID must be defined.')
