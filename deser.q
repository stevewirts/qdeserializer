\c 2000 2000
\d .d
\e 1

architectures: 0x0001!`bigendian`littleendian
messagetypes: 0x000102!`async`sync`response
attributes: 0x0001020304!`none`sorted`unique`partitioned`grouped

readRawBoolean:{0x01~x}
readRawByte:{first x}
readRawShort:{0x0 sv reverse x}
readRawInt:{readRawShort x}
readRawLong:{readRawShort x}
readRawReal:{first first (enlist 4;enlist "e")1: reverse x}
readRawFloat:{first first (enlist 8;enlist "f")1: reverse x}
readRawChar:{first "c"$x}
readRawSymbol:{`$"c"$-1 _ x}
readRawTimestamp:{"p"$readRawShort x}
readRawMonth:{"m"$readRawShort x}
readRawDate:{"d"$ readRawShort x}
readRawDatetime:{"z"$readRawFloat x}
readRawTimespan:{"n"$readRawShort x}
readRawMinute:{"u"$readRawShort x}
readRawSecond:{"v"$readRawShort x}
readRawTime:{"t"$readRawShort x}

arrayLength:{"j"$readRawInt 4 # 1_ x}
readArray:{x each ((arrayLength z;y) # (5_ z))}
readSymbolArray:{{`$"c"$(-1 _ x)} each (0,1+(where 0x00 = -1 _ (5_ x)))_ (5_ x)}

symbolByteLength:{1 + (first where x=0x00)}

symbolArrayByteLength:{
  l:arrayLength x;
  syms: 5_ x;
  (5+(where syms = 0x00)[l])}

generalListByteLength:{
 l:arrayLength x;
 m:5_ x;
 t:0;
 while[l>0;
  l:l-1;
  kType: types first m;
  eachlength: 1 + kType[3][1_ m];
  m:eachlength _ m;
  t:t + eachlength];
 5 + t}

readGeneralList:{
 l:arrayLength x;
 m:5_ x;
 r:(`a;1);
 while[l>0;
  l:l-1;
  kType: types first m;
  eachlength: 1 + kType[3][1_ m];
  e: readObject (eachlength # m);
  m:eachlength _ m;
  r,:e];
 2_ r}

readObject: {
 kType: types first x;
 v: kType[5][1_ x];
 enlist (first kType;v)}

types:(!). flip(
 (0xff;(`boolean;          1; "b"; {1}; 0b  ; readRawBoolean));                
 (0xfc;(`byte;             4; "x"; {1}; 0x00; readRawByte));               
 (0xfb;(`short;            5; "h"; {2}; 0Nh ; readRawShort));              
 (0xfa;(`int;              6; "i"; {4}; 0Nh ; readRawInt));                
 (0xf9;(`long;             7; "j"; {8}; 0Nj ; readRawLong));               
 (0xf8;(`real;             8; "e"; {4}; 0Ne ; readRawReal));               
 (0xf7;(`float;            9; "f"; {8}; 0n  ; readRawFloat));              
 (0xf6;(`char;            10; "c"; {1}; " " ; readRawChar));               
 (0xf5;(`symbol;          11; "s"; symbolByteLength;`;readRawSymbol));             
 (0xf4;(`timestamp;       12; "p"; {8}; 0Np ; readRawTimestamp));              
 (0xf3;(`month;           13; "m"; {4}; 0Nm ; readRawMonth));         
 (0xf2;(`date;            14; "d"; {4}; 0Nd ; readRawDate));         
 (0xf1;(`datetime;        15; "z"; {4}; 0Nz ; readRawDatetime));              
 (0xf0;(`timespan;        16; "n"; {8}; 0Nn ; readRawTimespan));               
 (0xef;(`minute;          17; "u"; {4}; 0Nu ; readRawMinute));            
 (0xee;(`second;          18; "v"; {4}; 0Nv ; readRawSecond));             
 (0xed;(`time;            19; "t"; {4}; 0Nt ; readRawTime));
 (0x00;(`general_list;     0; " "; generalListByteLength; () ; readGeneralList));    
 (0x01;(`boolean_array;    1; "b"; {5 + arrayLength x}; 0b  ; readArray[readRawBoolean; 1]));                
 (0x04;(`byte_array;       4; "x"; {5 + arrayLength x}; 0x00; readArray[readRawByte; 1]));               
 (0x05;(`short_array;      5; "h"; {5 + 2 * arrayLength x}; 0Nh ; readArray[readRawShort; 2]));              
 (0x06;(`int_array;        6; "i"; {5 + 4 * arrayLength x}; 0Nh ; readArray[readRawInt; 4]));                
 (0x07;(`long_array;       7; "j"; {5 + 8 * arrayLength x}; 0Nj ; readArray[readRawLong; 8]));               
 (0x08;(`real_array;       8; "e"; {5 + 4 * arrayLength x}; 0Ne ; readArray[readRawReal; 4]));               
 (0x09;(`float_array;      9; "f"; {5 + 8 * arrayLength x}; 0n  ; readArray[readRawFloat; 8]));              
 (0x0a;(`char_array;      10; "c"; {5 + arrayLength x}; " " ; readArray[readRawChar; 1]));               
 (0x0b;(`symbol_array;    11; "s"; symbolArrayByteLength; `   ; readSymbolArray));             
 (0x0c;(`timestamp_array; 12; "p"; {5 + 8 * arrayLength x}; 0Np ; readArray[readRawTimestamp; 8]));              
 (0x0d;(`month_array;     13; "m"; {5 + 4 * arrayLength x}; 0Nm ; readArray[readRawMonth; 4]));         
 (0x0e;(`date_array;      14; "d"; {5 + 4 * arrayLength x}; 0Nd ; readArray[readRawDate; 4]));         
 (0x0f;(`datetime_array;  15; "z"; {5 + 4 * arrayLength x}; 0Nz ; readArray[readRawDatetime; 8]));              
 (0x10;(`timespan_array;  16; "n"; {5 + 8 * arrayLength x}; 0Nn ; readArray[readRawTimespan; 8]));               
 (0x11;(`minute_array;    17; "u"; {5 + 4 * arrayLength x}; 0Nu ; readArray[readRawMinute; 4]));            
 (0x12;(`second_array;    18; "v"; {5 + 4 * arrayLength x}; 0Nv ; readArray[readRawSecond; 4]));             
 (0x13;(`time_array;      19; "t"; {5 + 4 * arrayLength x}; 0Nt ; readArray[readRawTime; 4])));

deser:{

 architecture: architectures first x;
 messagetype: messagetypes first 1 _ x;
 msglength: readRawInt -4#8# x;
 val: readObject 8_ x;

 (!). flip(
 (`architecture; architecture );
 (`messagetype;  messagetype );
 (`msglength; msglength);
 (`val; val)
 )}

\d .

m:-8!(1;"howdy doody";(1 2;1.1 2.2;(`def;"ghi")))

.d.deser m

/
.d.deser -8!0b
.d.deser -8!0x01
.d.deser -8!10h
.d.deser -8!10i
.d.deser -8!10
.d.deser -8!10.1e
.d.deser -8!10.1f
.d.deser -8!"a"
.d.deser -8!`superduper
.d.deser -8!2015.01.01D12:34:56.123456789
.d.deser -8!2015.12m
.d.deser -8!2015.12.12
.d.deser -8!2015.01.01T12:34:56.123
.d.deser -8!12:34:56.123456789
.d.deser -8!12:34
.d.deser -8!12:34:56
.d.deser -8!12:34:56.123
.d.deser -8!1010101010b
.d.deser -8!0x010203040506070809
.d.deser -8!0 1 2 3 4 5 6 7 8 9h
.d.deser -8!0 1 2 3 4 5 6 7 8 9i
.d.deser -8!0 1 2 3 4 5 6 7 8 9
.d.deser -8!0.0 1.1 2.2 3.3 4.4 5.5 6.6 7.7 8.8 9.9e
.d.deser -8!0.0 1.1 2.2 3.3 4.4 5.5 6.6 7.7 8.8 9.9f
.d.deser -8!"abcdefghimklmnopqrstuvwxyz"
.d.deser -8!`super`duper
.d.deser -8!2015.01.01D12:34:56.123456789 2015.01.01D12:34:56.987654321
.d.deser -8!2015.01 2015.02 2015.03m
.d.deser -8!2015.01.01 2015.02.02 2015.03.03
.d.deser -8!2015.01.01T12:34:56.123 2015.01.01T12:34:56.321
.d.deser -8!12:34:56.123456789 12:34:56.987654321
.d.deser -8!12:34 21:43
.d.deser -8!12:34:56 21:43:56
.d.deser -8!12:34:56.123 12:34:56.321