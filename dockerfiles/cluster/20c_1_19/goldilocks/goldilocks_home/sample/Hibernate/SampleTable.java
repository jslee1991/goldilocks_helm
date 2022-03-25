import java.math.BigInteger;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class SampleTable
{
    private long id;
    private String     name;
    private long       bigintValue;
    private int        intValue;
    private short      smallValue;
    private float      floatValue;
    private double     doubleValue;
    private BigInteger numericValue;
    private Date       dateValue;
    private Time       timeValue;
    private Timestamp  timestampValue;
    private byte[]     binaryValue;
    private String     longvarcharValue;
    private byte[]     longvarbinaryValue;
    
    public SampleTable()
    {
        this.name = null;
    }
    
    public SampleTable( String name )
    {
        this.name = name;
    }
    
    public long getId()
    {
        return id;
    }
    
    public void setId( long id )
    {
        this.id = id;
    }
    
    public String getName()
    {
        return name;
    }
    
    public void setName( String name )
    {
        this.name = name;
    }
    
    public long getBigintValue()
    {
        return this.bigintValue;
    }
    
    public void setBigintValue(long bigintValue)
    {
        this.bigintValue = bigintValue;
    }
    
    public int getIntValue()
    {
        return this.intValue;
    }
    
    public void setIntValue(int intValue)
    {
        this.intValue = intValue;
    }
    
    public short getSmallValue()
    {
        return this.smallValue;
    }
    
    public void setSmallValue(short smallValue)
    {
        this.smallValue = smallValue;
    }
    
    public float getFloatValue()
    {
        return this.floatValue;
    }
    
    public void setFloatValue(float floatValue)
    {
        this.floatValue = floatValue;
    }
    
    public double getDoubleValue()
    {
        return this.doubleValue;
    }
    
    public void setDoubleValue(double doubleValue)
    {
        this.doubleValue = doubleValue;
    }
    
    public BigInteger getNumericValue()
    {
        return this.numericValue;
    }
    
    public void setNumericValue(BigInteger numericValue)
    {
        this.numericValue = numericValue;
    }
    
    public Date getDateValue()
    {
        return this.dateValue;
    }
    
    public void setDateValue(Date dateValue)
    {
        this.dateValue = dateValue;
    }
    
    public Time getTimeValue()
    {
        return this.timeValue;
    }
    
    public void setTimeValue(Time timeValue)
    {
        this.timeValue = timeValue;
    }
    
    public Timestamp getTimestampValue()
    {
        return this.timestampValue;
    }
    
    public void setTimestampValue(Timestamp timestampValue)
    {
        this.timestampValue = timestampValue;
    }
    
    public byte[] getBinaryValue()
    {
        return this.binaryValue;
    }
    
    public void setBinaryValue(byte[] binaryValue)
    {
        this.binaryValue = binaryValue;
    }
    
    public String getLongvarcharValue() 
    {
        return this.longvarcharValue;
    }
    
    public void setLongvarcharValue(String longvarcharValue)
    {
        this.longvarcharValue = longvarcharValue;
    }
    
    public byte[] getLongvarbinaryValue()
    {
        return this.longvarbinaryValue;
    }

    public void setLongvarbinaryValue( byte[] longvarbinaryValue )
    {
        this.longvarbinaryValue = longvarbinaryValue;
    }
}

