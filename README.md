# MTA-BinaryDataTools
This resource gives ability to work on binary data formats, using the tools included here it's possible to read binary files, and write new ones.
The binary conversions are written in pure lua, meaning that they can be used outside of MTA ecosystem as well.
&nbsp;

 # Note about floating point formats
While i tried to make writing floating point formats as precise as i could, i can't guarantee in any way it will be perfect.
&nbsp;

# File structure:
 - The resource is made of 3 classes:
   - BinaryWriter class, each instance of this class is new writer, it's used to write binary data to files or string, converted to binary from normal lua formats.
   - BinaryReader class, each instance of this class is new reader, it's used to read binary data from files or strings, and convert it to lua data formats using BinaryConverter class.
   - BinaryConverter class, it's a singleton that provides functions used to convert binary data to lua data formats and lua formats back to binary (functions used to convert from binary data to lua are based on https://github.com/tederis/mta-resources/blob/master/dffframe/bytedata.lua)
 - This resource doesn't export any functions because custom classes can't be exported properly along with their metatables easily.

# Operating on binary files
Example code showing usage of BinaryWriter to write lua data as binary, and convert it back to lua formats.
```lua
    -- Create binary writer, with empty string as base data
    local writer = BinaryWriter("")\
    -- Write some data using the writer
    writer:WriteString("TestString")
    writer:WriteFloat(69.42069)
    writer:WriteInt32(342352)
    writer:WriteString("TestString2")
    writer:WriteUInt8(218)
    writer:WriteUInt16(42069)
    writer:WriteFloat(0.21e-5)
    writer:WriteDouble(math.huge)
    writer:WriteHalf(0/0)

    -- Create binary reader, feed it current data from previously created 
    local reader = BinaryReader(writer:GetCurrentString())
    outputConsole( reader:ReadString() )
    outputConsole( reader:ReadFloat() )
    outputConsole( reader:ReadInt32() )
    outputConsole( reader:ReadString() )
    outputConsole( reader:ReadUInt8() )
    outputConsole( reader:ReadUInt16() )
    outputConsole( reader:ReadFloat() )
    outputConsole( reader:ReadDouble() )
    outputConsole( reader:ReadHalf() )

    -- This will result with these data being outputed into console:
    -- TestString
    -- 69.420684814453
    -- 342352
    -- TestString2
    -- 218
    -- 42069
    -- 2.0999996195314e-06
    -- inf
    -- -nan(ind)
```   

# All functions availible for BinaryConverter:
```lua
    BinaryConverter:SetEndianness( endianness ) --Sets whether conversions should use little endian, or big endian memory layout 
    BinaryConverter:ToBinaryString( num, bits ) --Prints binary representation of given number with up to *bits* chars

    BinaryConverter:FromInt64( str ) --Converts from string of length 8 to 64bit signed integer
    BinaryConverter:FromInt32( str ) --Converts from string of length 4 to 32bit signed integer
    BinaryConverter:FromInt16( str ) --Converts from string of length 2 to 16bit signed integer
    BinaryConverter:FromInt8 ( str ) --Converts from string of length 1 to 8bit  signed integer

    BinaryConverter:FromUInt64( str ) --Converts from string of length 8 to 64bit unsigned integer
    BinaryConverter:FromUInt32( str ) --Converts from string of length 4 to 32bit unsigned integer
    BinaryConverter:FromUInt16( str ) --Converts from string of length 2 to 16bit unsigned integer
    BinaryConverter:FromUInt8 ( str ) --Converts from string of length 1 to 8bit  unsigned integer

    BinaryConverter:FromDouble( str ) --Converts from string of length 8 to 64 bit floating point number
    BinaryConverter:FromFloat ( str ) --Converts from string of length 4 to 32 bit floating point number
    BinaryConverter:FromHalf  ( str ) --Converts from string of length 2 to 16 bit floating point number

    BinaryConverter:FromCharArray( str ) --Converts null terminater string into normal lua string

    BinaryConverter:ToInt64( num ) --Converts number into 64bit signed integer written as string of length 8
    BinaryConverter:ToInt32( num ) --Converts number into 32bit signed integer written as string of length 4
    BinaryConverter:ToInt16( num ) --Converts number into 16bit signed integer written as string of length 2
    BinaryConverter:ToInt8 ( num ) --Converts number into 8bit  signed integer written as string of length 1

    BinaryConverter:ToUInt64( num ) --Converts number into 64bit unsigned integer written as string of length 8
    BinaryConverter:ToUInt32( num ) --Converts number into 32bit unsigned integer written as string of length 4
    BinaryConverter:ToUInt16( num ) --Converts number into 16bit unsigned integer written as string of length 2
    BinaryConverter:ToUInt8 ( num ) --Converts number into 8bit  unsigned integer written as string of length 1

    BinaryConverter:ToDouble( num ) --Converts number into 64bit floating point number written as string of length 8
    BinaryConverter:ToFloat ( num ) --Converts number into 32bit floating point number written as string of length 4
    BinaryConverter:ToHalf  ( num ) --Converts number into 16bit floating point number written as string of length 2

    BinaryConverter:ToCharArray( str ) --Converts lua string into null terminated string
```

# All functions availible for BinaryWriter:
```lua
    BinaryWriter( string/file ) --Creates new instance of BinaryWriter, that will write to given string/file. I will call this given string/file *stream* in further comments
    BinaryWriter:GetCurrentString() --Gives either the content of whole file if it's writing into it, or entire string with binary data in it

    BinaryWriter:WriteInt64( num ) --Writes 64bit signed integer into stream
    BinaryWriter:WriteInt32( num ) --Writes 32bit signed integer into stream
    BinaryWriter:WriteInt16( num ) --Writes 16bit signed integer into stream
    BinaryWriter:WriteInt8 ( num ) --Writes 8bit  signed integer into stream

    BinaryWriter:WriteUInt64( num ) --Writes 64bit unsigned integer into stream
    BinaryWriter:WriteUInt32( num ) --Writes 32bit unsigned integer into stream
    BinaryWriter:WriteUInt16( num ) --Writes 16bit unsigned integer into stream
    BinaryWriter:WriteUInt8 ( num ) --Writes 8bit  unsigned integer into stream

    BinaryWriter:WriteDouble( num ) --Writes 64bit floating point into stream
    BinaryWriter:WriteFloat ( num ) --Writes 32bit floating point into stream
    BinaryWriter:WriteHalf  ( num ) --Writes 16bit floating point into stream

    BinaryWriter:WriteString( num ) --Writes null terminated string into stream
```

# All functions availible for BinaryReader:
```lua
    BinaryReader( string/file ) --Creates new instance of BinaryReader, that will read from given string/file. I will call this given string/file *stream* in further comments

    BinaryReader:ReadInt64( num ) --Reads 64bit signed integer from stream
    BinaryReader:ReadInt32( num ) --Reads 32bit signed integer from stream
    BinaryReader:ReadInt16( num ) --Reads 16bit signed integer from stream
    BinaryReader:ReadInt8 ( num ) --Reads 8bit  signed integer from stream

    BinaryReader:ReadUInt64( num ) --Reads 64bit unsigned integer from stream
    BinaryReader:ReadUInt32( num ) --Reads 32bit unsigned integer from stream
    BinaryReader:ReadUInt16( num ) --Reads 16bit unsigned integer from stream
    BinaryReader:ReadUInt8 ( num ) --Reads 8bit  unsigned integer from stream

    BinaryReader:ReadDouble( num ) --Reads 64bit floating point from stream
    BinaryReader:ReadFloat ( num ) --Reads 32bit floating point from stream
    BinaryReader:ReadHalf  ( num ) --Reads 16bit floating point from stream

    BinaryReader:ReadString( num ) --Reads null terminated string from stream
```

License
----
> ----------------------------------------------------------------------------
> Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
> notice, you can do whatever you want with this stuff. If we
> meet someday, and you think this stuff is worth it, you can
> buy me a beer in return.
 ----------------------------------------------------------------------------