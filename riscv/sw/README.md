This folder the resources needed to build software for the little risc v core.  
  
You need to install:
- python3
- intelhex python library

Edit main.c and run `make compile`.  
This creates **build** directory with **rom.v** file you can include as rom software memory in verilog design.  
**rom** folder contains some prebuild example rom.
