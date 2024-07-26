# 32-bit-PIC-with-fixed-priority

# Overview
This project implements a 32-bit interrupt controller designed with a fixed priority order for all peripheral devices. The priority order is preset and cannot be changed dynamically. The controller operates in Automatic End of Interrupt (AEOI) mode, eliminating the need for an End of Interrupt (EOI) signal.

# Features
- # 32-bit Interrupt Controller:
- Supports up to 32 interrupt lines for peripheral devices.
- # Fixed Priority Order:
- Priority for interrupt lines is fixed and cannot be adjusted dynamically.
- # Automatic End of Interrupt (AEOI) Mode:
- No need for an End of Interrupt (EOI) line, simplifying the interrupt handling process.
- # Efficient Interrupt Handling:
- Ensures that interrupts are handled based on the fixed priority order, providing consistent and predictable behavior.
# Components
- # Interrupt Request Lines (IRQ):
-32 interrupt lines for peripheral devices.
- # Priority Resolver:
- Encodes the interrupt requests based on the fixed priority order.
- Ensures the highest priority interrupt is selected for servicing.
- # Interrupt Service Register (ISR):
- Holds the record of the interrupt that is currently being served.
- Allows quick and efficient response to interrupts.
- # Vector Address Register:
- Holds the vector address of each interrupt lines.
- Sends the address of the interrupt request that is currently being served through data bus.
- # Control Logic:
- Manages the servicing of interrupts based on the fixed priority order.
- Handles the AEOI mode operation.
