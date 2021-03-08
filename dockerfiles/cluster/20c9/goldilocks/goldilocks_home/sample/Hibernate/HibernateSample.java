import java.util.Iterator;
import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.HibernateException; 

import java.math.BigInteger;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class HibernateSample
{
    private static SessionFactory mFactory;
    
    public static void main( String[] args )
    {
        try 
        {
            mFactory = new Configuration().configure( "hibernate.conf.xml" ).buildSessionFactory();
        }
        catch (Throwable ex) 
        {
            System.err.println( "Failed to create sessionFactory object." + ex);
            throw new ExceptionInInitializerError(ex);
        }
        
        HibernateSample sHibernateSample = new HibernateSample();
        long       bigintValue = 10000;
        int        intValue = 1000;
        short      smallValue =255;
        float      floatValue = 1.99F;
        double     doubleValue = 19999.99999;
        BigInteger numericValue = new BigInteger( "199" );
        Date       dateValue = new Date( 117 );
        Time       timeValue = new Time( 117 );
        Timestamp  timestampValue = new Timestamp( 1117 );
        byte[]     binaryValue = { 'a', 'b', 'c', 'd' };
        String     longvarcharValue = new String( "long varchar" );
        byte[]     longvarbinaryValue = { 'a', 'b', 'c', 'd', 'e' };

        Long sSt1 = sHibernateSample.addSample( "Marin" );
        Long sSt2 = sHibernateSample.addSample( "Bengi" );
        Long sSt3 = sHibernateSample.addSample( "Faker" );
        Long sSt4 = sHibernateSample.addSample( "Bang" );
        Long sSt5 = sHibernateSample.addSample( "Wolf" );
        Long sSt6 = sHibernateSample.addSample( "Blank" );
        Long sSt7 = sHibernateSample.addSample( "KKoma" );

        sHibernateSample.fetchSample( 0, 0 );
        
        sHibernateSample.updateSample( sSt1, 
                "Huni", 
                bigintValue, 
                intValue, 
                smallValue,
                floatValue, 
                doubleValue, 
                numericValue, 
                dateValue, 
                timeValue, 
                timestampValue, 
                binaryValue,
                longvarcharValue,
                longvarbinaryValue );
        sHibernateSample.updateSample( sSt2, 
                "Peanut", 
                bigintValue, 
                intValue, 
                smallValue,
                floatValue, 
                doubleValue, 
                numericValue, 
                dateValue, 
                timeValue, 
                timestampValue, 
                binaryValue,
                longvarcharValue,
                longvarbinaryValue );
        
        sHibernateSample.deleteSample( sSt7 );
        
        sHibernateSample.fetchSample( 0, 0 );
        sHibernateSample.fetchSample( 1, 2 );

        sHibernateSample.closeFactory();
    }

    public void closeFactory()
    {
        mFactory.close();
    }
    
    public Long addSample( String name ) 
    {
        Session session = mFactory.openSession();
        Transaction tx = null;
        Long id = null;
        
        try 
        {
            tx = (Transaction) session.beginTransaction();
            SampleTable sample = new SampleTable( name );
            
            id = (Long) session.save(sample);
            tx.commit();
            
            System.out.println("add success");
        } 
        catch( HibernateException e) 
        {
            if( tx != null ) 
            {
                tx.rollback();
            }
            System.out.println("add fail");
            e.printStackTrace();
        } 
        finally 
        {
            session.close();
        }
        return id;
    }
    
    public void fetchSample( int offset, int count )
    {
        Session session = mFactory.openSession();
        Transaction tx = null;
        Query query = null;
        
        try{
            tx = session.beginTransaction();
            
            query = session.createQuery( "FROM SampleTable" );
            
            query.setFirstResult( offset );
            query.setMaxResults( count );
            query.setFetchSize( 20 );
            
            @SuppressWarnings( "unchecked" )
            List<SampleTable> samples = (List<SampleTable>) query.list();
            
            for( Iterator<SampleTable> iter = samples.iterator(); iter.hasNext(); ) 
            {
                SampleTable sample = (SampleTable) iter.next();
                System.out.print( "id: " + sample.getId() );
                System.out.print( " name: " + sample.getName() );
                System.out.print( " bigintValue: " + sample.getBigintValue() );
                System.out.print( " intValue: " + sample.getIntValue() );
                System.out.print( " smallValue: " + sample.getSmallValue() );
                System.out.print( " floatValue: " + sample.getFloatValue() );
                System.out.print( " doubleValue: " + sample.getDoubleValue() );
                System.out.print( " numericValue: " + sample.getNumericValue() );
                System.out.print( " dateValue: " + sample.getDateValue() );
                System.out.print( " timeValue: " + sample.getTimeValue() );
                System.out.print( " timestampValue: " + sample.getTimestampValue() );
                System.out.print( " binaryValue: " + sample.getBinaryValue() );
                System.out.print( " longvarcharValue: " + sample.getLongvarcharValue() );
                System.out.println( " longvarbinaryValue: " + sample.getLongvarbinaryValue() );
            }
            
            tx.commit();
        } 
        catch ( HibernateException e ) 
        {
            e.printStackTrace();
        } 
        finally 
        {
            session.close();
        }
    }
    
    public void updateSample( long id, 
            String name,
            long bigintValue, 
            int intValue, 
            short smallValue,
            float floatValue,
            double doubleValue,
            BigInteger numericValue,
            Date dateValue, 
            Time timeValue, 
            Timestamp timestampValue,
            byte[] binaryValue,
            String longvarcharValue,
            byte[] longvarbinaryValue )
    {
        Session session = mFactory.openSession();
        Transaction tx = null;
        
        try 
        {
            tx = session.beginTransaction();

            SampleTable sample = (SampleTable) session.get( SampleTable.class, id );
            sample.setName( name );
            sample.setBigintValue( bigintValue );
            sample.setIntValue( intValue );
            sample.setSmallValue( smallValue );
            sample.setFloatValue( floatValue );
            sample.setDoubleValue( doubleValue );
            sample.setNumericValue( numericValue );
            sample.setDateValue( dateValue );
            sample.setTimeValue( timeValue );
            sample.setTimestampValue( timestampValue );
            sample.setBinaryValue( binaryValue );
            sample.setLongvarcharValue( longvarcharValue );
            sample.setLongvarbinaryValue( longvarbinaryValue );
            session.update( sample );
            
            tx.commit();
            
            System.out.println( "update success" );
        }
        catch ( HibernateException e ) 
        {
            if( tx != null )
            {
                tx.rollback();
            }
            System.out.println("update fail");
            e.printStackTrace();
        } 
        finally 
        {
            session.close();
        }
        
    }
    
    public void deleteSample( long id ) 
    {
        Session session = mFactory.openSession();
        Transaction tx = null;
        
        try 
        {
            tx = session.beginTransaction();
            SampleTable sample = (SampleTable) session.get( SampleTable.class, id );       
            session.delete( sample );
            tx.commit();
            
            System.out.println( "delete success" );
        } 
        catch ( HibernateException e ) 
        {
            if( tx != null ) {
                tx.rollback();
            }
            
            System.out.println("delete fail");
            e.printStackTrace();
        } 
        finally 
        {
            session.close();
        }
    }
}

