# Module Overview
The Aligner module takes in an unligned steam of data and outputs it as an aligned stream of data based on its configuration.
Its purpose is to optemize writes in memory by performing only the writes best suited for the type of memory used in the system
# Block Diagram
  ![Screenshot 2025-04-07 184950](https://github.com/user-attachments/assets/822743bb-87aa-4a8a-95e7-5d0e6a719717)
# Functionality:
The figure below shows how the alignment is done based on different values for CTRL.SIZE and CTRL.OFFSET while the ALGN_DATA_WIDTH is 32:
- CTRL.SIZE = 1 and CTRL.OFFSET = 0
![Screenshot 2025-04-07 192333](https://github.com/user-attachments/assets/9ad3fd0e-69a6-40a6-b2bd-c49c7e6ff980)
- CTRL.SIZE = 2 and CTRL.OFFSET = 2
![Screenshot 2025-04-07 192347](https://github.com/user-attachments/assets/9f3a0ef1-6e6b-4c0f-8a56-60da8cdd798a)

### Interface:
The aligner module uses two types of interfaces.
- Standard AMBA 3 APB for accessing the registers
- Two interfaces uses the same custom MD protocol (TX - RX).

### Registers:
The aligenr module has several control and status registers accesseible through the APB interface.
The following rules govern the scenarios in which the Aligner must return an APB error:
* Any access to a location on which no register is mapped must return an APB error.
* Any write access to a full read-only register must return an APB error.
* Any read access from a full write-only register must return an APB error.
* Illegal write access to the Control register
### Below is the list of registers:
- CTRL   ----> Control Register.
- STATUS ----> Status Register.
- IRQEN  ----> Interupt Request Enable Register.
- IRQ    ----> Interupt request Register.

# Testbench Environment
![image](https://github.com/user-attachments/assets/66dbb560-86a7-4640-8744-9d65207dcaae)

# UVM Extension Package:
This package includes all the common code in the environment and this help us to reuse the code (one of the main features of UVM). This helps us build advanced UVM agents with its components and only override the needed component in our agents based on our need.
![image](https://github.com/user-attachments/assets/605afa38-4f33-42cf-8701-dc77b30bde5d)
## The hierarchy of the uvm_ext_pkg illustrated below:
![ext_pkg](https://github.com/user-attachments/assets/99826d37-c037-4d84-937d-eb6fc4825bf2)

# APB Package:
- APB package contains all the neccessary components for apb agent.
  





















