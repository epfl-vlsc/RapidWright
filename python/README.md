Python Wrapper for RapidWright from Xilinx, Inc.

# How to Install RapidWright for Python 3
```
pip install rapidwright
```

# How it Works
RapidWright is written in Java, however, a project called [jpype1](https://github.com/jpype-project/jpype) allows Python to natively access the JVM and provide access to Java libraries.  Here is how you can use RapidWright in your Python scripts and programs:
```
# This will start a JVM instance 
import rapidwright

# These import Java classes as Python modules
from com.xilinx.rapidwright.examples import Lesson1
from com.xilinx.rapidwright.design import Design

# Create a basic design DCP, read it back in and print out the cells
Lesson1.main([])
design = Design.readCheckpoint("HelloWorld.dcp")
print(design.getCells())
```

Output:
```
==============================================================================
==                       Writing DCP: HelloWorld.dcp                        ==
==============================================================================
              Write EDIF:     0.002s
     Writing XDEF Header:     0.041s
  Writing XDEF Placement:     0.033s
    Writing XDEF Routing:     0.051s
 Writing XDEF Finalizing:     0.010s
             Writing XDC:     0.014s
------------------------------------------------------------------------------
         [No GC] *Total*:     0.149s
==============================================================================
==                       Reading DCP: HelloWorld.dcp                        ==
==============================================================================
 XML Parse & Device Load:     0.002s
              EDIF Parse:     0.003s
        Read XDEF Header:     0.008s
        Read XDEF Caches:     0.003s
     Read XDEF Placement:     0.005s
       Read XDEF Routing:     0.044s
------------------------------------------------------------------------------
         [No GC] *Total*:     0.065s
[and2(BEL: A6LUT), led0(BEL: OUTBUF), button0(BEL: INBUF_EN), button1(BEL: INBUF_EN)]

```