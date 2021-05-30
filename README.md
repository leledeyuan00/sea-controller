# SEA Controller

This is the project for a controller architechture consisted of FPGA and STM32.

`FreeRTOS` is the project for STM32. There is a 1kHz control frequency on it.

`SEA_FPGA` is the project for FPGA. There is a 10kHz control frequency on it.

## Environment

| Product | IDE | Vendor |
|:-----:|:-----:|:-----:|
| STM32 | Keil | STM32F429ZG|
| FPGA  | Quartus  |Altera Cyclone Ⅳ EP4CE6|

## FPGA

In `SEA_FPGA/controller/`directory, there is a `nominal_top.v` file, which is a combination of all of control algorithms coded here. And you can switch controller algorithm like PID or SMC by edit this file directly.