# UART Communication System Using Verilog HDL
A basic UART(Universal Asynchronous Receiver-Transmitter) communication system designed and simulated using Verilog HDL

## Project Status
Completed

## Overview
This project implements a UART communication system using Verilog HDL.
The system is designed to transmit and receive serial data using the UART communication protocol. A Verilog testbench was used to verify the operation of the transmitter and receiver through simulation.

## Tools Used
- Verilog HDL
- EDA Playground

## System Components
The project consists of:
- UART Transmitter
- UART Receiver
- Baud-rate generation
- Verilog testbench
- Serial data transmission and reception

## Working
The UART transmitter converts parallel data into a serial data stream for transmission.
The UART receiver accepts the serial data stream and converts it back into parallel data.
The transmitter and receiver were tested using a Verilog testbench to verify that the transmitted data was correctly received.

## Simulation Result
The system was tested by transmitting the hexadecimal value:
'A5'
The receiver successfully obtained:
'A5'
The simulation completed successfully.

## Files
The Verilog source files and testbench are included in this repository.

## Simulation
The design was simulated using EDA Playground with a Verilog testbench.

## What I Learned
- Basics of Verilog HDL
- UART communication
- Serial data transmission and reception
- Writing Verilog testbenches
- Simulation and waveform verification
- Debugging HDL designs
