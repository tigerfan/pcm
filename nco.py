from amaranth import *
from amaranth.back import verilog
from amaranth.sim import Simulator, Settle
import sys

class NCO(Elaboratable):
    def __init__(self, width):
        self.width = width
        self.phase_acc = Signal(width)
        self.freq_ctrl = Signal(width)
        self.output = Signal()

    def elaborate(self, platform):
        m = Module()

        # Phase Accumulator
        m.d.sync += self.phase_acc.eq(self.phase_acc + self.freq_ctrl)

        # Output (MSB of the phase accumulator)
        m.d.comb += self.output.eq(self.phase_acc[-1])  # Using MSB as output

        return m

# Testbench
def testbench(sim_time_sec):
    width = 16  # Width of the phase accumulator
    nco = NCO(width)
    sim = Simulator(nco)
    sim.add_clock(1e-6)  # 1 MHz clock for simulation

    def process():
        # Initialize control frequency
        yield nco.freq_ctrl.eq(1000)  # Set frequency control word
        sim_time_cycles = int(sim_time_sec * 1e3)  # Convert seconds to clock cycles
        for _ in range(sim_time_cycles):
            yield
            print(f"Output: {yield nco.output}")

    sim.add_sync_process(process)
    with sim.write_vcd("nco.vcd", "nco.gtkw"):
        sim.run()

if __name__ == "__main__":
    if "--sim" in sys.argv:
        idx = sys.argv.index("--sim")
        if len(sys.argv) > idx + 1:
            sim_time_sec = float(sys.argv[idx + 1])
        else:
            sim_time_sec = 1.0  # Default simulation time in seconds
        testbench(sim_time_sec)
    else:
        width = 16  # Width of the phase accumulator
        nco = NCO(width)
        with open("nco.v", "w") as f:
            f.write(verilog.convert(nco, name="nco", ports=[nco.freq_ctrl, nco.output]))
