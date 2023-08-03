# MCOI APP
Here we can leave recored of issues and general notes of development 

# Standalone build
This option is not ready yet (makefile is in the build folder), it can build
the application without the fsbl.elf, and being able to configure the jtag run
option. This option would simplify the structure of the mcoi project but it
needs higher amount of time to be invested in workaround of the vitis IDE. 

# VITIS project
1. navigate to vitis folder
```
$> cd vitis
```

2. build all platform and application project
```
$> make
```

3. import the project in vitis by navigating to path/to/build (open all the
   projects available in build folder)
4. set the RUN and DEBUG configuration as it is described in the official guide
   for [reference design from enclustra](https://github.com/enclustra/Mercury_XU5_PE1_Reference_Design/tree/master/reference_design/doc)
5. If you need to recompile platform project the platform.spr file has to be
   opened, when we want to compile it for the first time

# NOTES 
* if we want to use Vitis, we cannot have the Makefile in the root directory
