# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("=== Start Stopwatch Test ===")

    # -----------------------
    # Clock setup
    # -----------------------
    # Create a 100 kHz clock (period = 10 us)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # -----------------------
    # Reset sequence
    # -----------------------
    dut._log.info("Resetting DUT")
    dut.ena.value = 1          # TinyTapeout requires ena=1 when active
    dut.ui_in.value = 0        # clear user inputs (start/stop)
    dut.uio_in.value = 0       # tie off bidir inputs
    dut.rst_n.value = 0        # assert reset (active-low)
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1        # release reset
    await ClockCycles(dut.clk, 5)

    # -----------------------
    # Apply stimulus
    # -----------------------
    dut._log.info("Starting stopwatch")
    dut.ui_in.value = 0b00000001   # start = 1, stop = 0
    await ClockCycles(dut.clk, 100)  # wait 100 cycles (simulation short)

    dut._log.info("Stopping stopwatch")
    dut.ui_in.value = 0b00000010   # start = 0, stop = 1
    await ClockCycles(dut.clk, 10)

    # -----------------------
    # Check results
    # -----------------------
    dut._log.info(f"uo_out = {dut.uo_out.value}")
    dut._log.info(f"uio_out = {dut.uio_out.value}")

    # Example assertion: uo_out should not be all zeros after running
    assert dut.uo_out.value.integer != 0, "Stopwatch did not count!"

    dut._log.info("=== Stopwatch Test PASSED ===")
