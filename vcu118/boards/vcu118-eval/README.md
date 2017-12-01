# VCU118 firmware infrastructure implementation 

The device will run MP7-like algorithms at some algo clock frequence (240 MHz for a start), reading from and writing to bram buffers.

The buffers and the control infrastructure will be managed via IPbus using the ethernet port.

## Clocking

There's three input clocks:
 * a 300 MHz board clock, from which we currently derive via MMCM:
   * the 240 MHz clock for the algorithm
   * the 30 MHz clock for ipbus
 * a 125 MHz board clock, which is used for timing the reset signals
 * a 625 MHz sgmii ethernet clock from the external device
   * from this, the SGMII adapter IP core derives a 125 MHz ethernet clock that we use to clock the TEMAC

*TODO*:
 * understand if it would be better to derive the ipbus clock from the 125 MHz system clock.

## I/O data buffers
These are currently plain BRAMS but should be replaced with [ipbus_ported_dpram36](https://github.com/ipbus/ipbus-firmware/blob/master/components/ipbus_slaves/firmware/hdl/ipbus_ported_dpram36.vhd). 
  * Current addresses are also wrongm (they're bit addresses, not word addresses), but it doesn't matter since that part will change when moving to the ipbus buffer

Buffers are always looping, both the injection and the capture one.
  * We should probably introduce a few null frames (valid bit off) at the very beginning of the inject buffer to align the algorithm.
  * We may also need a way to check/enforce that the counters of all buffers are synchronized; either we keep just one counter and propagate it all the way to the buffers, or we make a reset line that arrives synchronously to all the buffers via some number of registers to reset all the counters simultaneously. 

## Ethernet

The FPGA is connected to an external 10/100/1000 PHY device via SGMII interface, with:
 * two LVDS pairs for input and output
 * one LVDS pair for the 625 MHz received clock
 * power on, reset
 * MDIO/MDC management interface (which we don't yet know how to use)

We use the Xilinx IP core "1G/2.5G Ethernet PCS/PMA or SGMII v16.1" to access the device.
As the pins are not connected to a GT transceiver, we rely on the "Asynchronous SGMII over LVDS" solution (all the native SelectIO interfaces are hidden inside the core).
The SGMII core is then interfaced to the Xilinx standard tri-state ethernet MAC (TEMAC), which in turn talks to IPbus.

**TODO**: A few things to be understood:
 * do we need the MDIO/MDC? the TEMAC used by the MP7 doesn't have MD outputs, and the SGMII core only forwards MD commands from in to out, so we would have to re-generate also the TEMAC core (and, does the TEMAC know what to output on those ports?)
   * alternatively, do we need to use IPbus to control them?
 * do we need pipeline registers between the TEMAC and SGMII, or between IPbus and TEMAC? (the MP7 doesn't have them)
 * what is the `signal_detect_0` port of the SGMII core?
 * do we need auto-negotiation? do we need support for lower speeds than 1000bps? 
 * is there any other status signal of a successfull ethernet connection other than the locked signal from the SGMII core?

## IPbus

What we need is:
 * a hard reset
 * a soft reset (algo only)
 * access to the injection buffers and capture buffers

We can partition the address space in thwo or three:
 * a system part, that stays within the vcu118 infrastructure domain
 * a data part, that is used to read & write the buffers
 * possibly a user part, that may be used by the algorithm
 
*TODO*: everything

## Reset sequence

The reset sequence is modelled from the [kcu105 ipbus example](https://github.com/ipbus/ipbus-firmware/blob/master/boards/kcu105/base_fw/kcu105_basex/synth/firmware/hdl/kcu105_basex.vhd). Differences are _in italic_.
 * the sequence is clocked from a free running 125 MHz system clock
 * A 2 kHz clock starts ticking after 16 cycles of the system clock. This doomsday clock is never reset.
 * A hard reset signal exists, that is turned on via ipbus (with an added 1ms delay) or triggered by the main clock MCM going out of lock. _In the VCU118 we also allow triggering the reset via a physical button on the board (still with 1ms delay)_.
   * this hard reset is set to the ipbus system (control and slaves), _and also to the algorithms (synchronized to the algo clock and 40 MHz clock)_.
   * after one clock delay (500&mu;s) the reset is sent also to the ethernet system
     * the ethernet reset goes both to the TEMAC, to the PCS/PMA core, _and also to the external device_ (the specifications of the device require a minimum resut pulse of 1&mu;s, so these 500&mu;s is plenty enough)
     * the reset to the TEMAC is held high until the PCS/PMA core has completed its reset, and the MMC inside the core has locked the clock.
   * a reset for the client domain of the ethernet (mac part of ipbus control) is held high if the hard reset is on, or the ethernet system is not yet ready; this reset is in synch with the 125 MHz ethernet clock
 * both the hard reset and the ethernet reset start high at boot, so all the logic is reset for the first 500&mu;s, then the ethernet is reset for 500 &mus; (plus, for the MAC, the time the PCS/PMA needs to complete the reset sequence), and the ethernet client domain is held at reset from boot to when the ethernet system is ready
 * a soft reset also exists. the soft reset is turned on via ipbus, and stays on for 16 ipbus clock cycles. the soft reset is only set to the ipbus slaves, not to the control nor to the system. _Currently the soft reset logic is missing in the VCU118_
 * _the algorithm and ipbus slave reset signals go into BUFGs_; at least for the algorithm, this is needed to avoid timing violations when resetting items that are far away from the IPbus core.

*TODO*:
 * understand if the algorithm reset signals should go into BUFGs
 * understand if we need some delay between the resets to TEMAC, SGMII and PHY.

