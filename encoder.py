from amaranth import *
from amaranth.build import *
from amaranth.back import verilog
from amaranth.sim import Simulator, Delay, Settle

class IRIGBEncoder(Elaboratable):
    def __init__(self):
        # Input registers for time information
        self.seconds = Signal(6)  # 0-59
        self.minutes = Signal(6)  # 0-59
        self.hours = Signal(5)    # 0-23
        self.days = Signal(9)     # 1-365

        # Signal to set time externally
        self.set_time = Signal()  # High to load external time

        # Output for PWM signal
        self.pwm_out = Signal()

        # Internal counter for seconds
        self.internal_seconds = Signal(32)  # Large enough to count a year's worth of seconds

    def elaborate(self, platform: Platform) -> Module:
        m = Module()

        # Constants
        CLK_FREQ = 10_000  # 10 kHz
        SECONDS_IN_A_DAY = 86400  # 24 * 60 * 60
        TICKS_PER_SECOND = CLK_FREQ  # Ticks per second

        # Counters
        bit_counter = Signal(range(100))  # Counter for bits in the frame
        clk_counter = Signal(range(TICKS_PER_SECOND))  # Counter for clock cycles in one second

        # Internal second counter logic
        with m.If(self.set_time):
            # When set_time is high, load the external time
            total_seconds = Signal(32)
            m.d.comb += total_seconds.eq(
                ((self.days - 1) * SECONDS_IN_A_DAY) +
                (self.hours * 3600) +
                (self.minutes * 60) +
                self.seconds
            )
            m.d.sync += self.internal_seconds.eq(total_seconds)
        with m.Else():
            # Normal counting logic
            with m.If(clk_counter == TICKS_PER_SECOND - 1):
                m.d.sync += clk_counter.eq(0)
                with m.If(self.internal_seconds == 365 * SECONDS_IN_A_DAY - 1):
                    m.d.sync += self.internal_seconds.eq(0)
                with m.Else():
                    m.d.sync += self.internal_seconds.eq(self.internal_seconds + 1)
            with m.Else():
                m.d.sync += clk_counter.eq(clk_counter + 1)

        # Calculate the current day, hour, minute, and second from the internal counter
        current_day = Signal(9)
        current_hour = Signal(5)
        current_minute = Signal(6)
        current_second = Signal(6)

        bin_tod = Signal(18)

        m.d.comb += [
            current_day.eq(self.internal_seconds // SECONDS_IN_A_DAY + 1),
            current_hour.eq((self.internal_seconds % SECONDS_IN_A_DAY) // 3600),
            current_minute.eq((self.internal_seconds % 3600) // 60),
            current_second.eq(self.internal_seconds % 60),

            bin_tod.eq(self.internal_seconds % SECONDS_IN_A_DAY),
        ]

        # Convert time to BCD and split into digits
        def to_bcd_split(value, bits):
            nibbles = [Signal(4) for _ in range(bits // 4)]
            for i in range(bits // 4):
                m.d.comb += nibbles[i].eq((value // (10 ** i)) % 10)
            return nibbles

        bcd_seconds = to_bcd_split(current_second, 8)
        bcd_minutes = to_bcd_split(current_minute, 8)
        bcd_hours = to_bcd_split(current_hour, 8)
        bcd_days = to_bcd_split(current_day, 12)

        # PWM generation logic
        BIT_DURATION = CLK_FREQ // 100  # Duration of one bit (100 bits per second)
        bit_clk_counter = Signal(range(BIT_DURATION))  # Counter for clock cycles in one bit duration

        with m.If(bit_clk_counter == BIT_DURATION - 1):
            m.d.sync += bit_clk_counter.eq(0)
            m.d.sync += bit_counter.eq(bit_counter + 1)
            # If we reach the end of the bit frame, reset bit counter
            with m.If(bit_counter == 99):
                m.d.sync += bit_counter.eq(0)
        with m.Else():
            m.d.sync += bit_clk_counter.eq(bit_clk_counter + 1)

        # Time information as an array of bits (100 bits total)
        time_bits = Array(Signal() for _ in range(100))

        # Set the frame synchronization bits ("P" code) at the specified positions
        for i in [0, 9, 19, 29, 39, 49, 59, 69, 79, 89, 99]:
            m.d.comb += time_bits[i].eq(1)

        # Encoding seconds (bits 1-4)
        for i in range(4):
            m.d.comb += time_bits[1 + i].eq(bcd_seconds[0][i])

        # Encoding seconds (bits 6-8)
        for i in range(3):
            m.d.comb += time_bits[6 + i].eq(bcd_seconds[1][i])

        # Encoding minutes (bits 10-13)
        for i in range(4):
            m.d.comb += time_bits[10 + i].eq(bcd_minutes[0][i])

        # Encoding minutes (bits 15-17)
        for i in range(3):
            m.d.comb += time_bits[15 + i].eq(bcd_minutes[1][i])

        # Encoding hours (bits 20-23)
        for i in range(4):
            m.d.comb += time_bits[20 + i].eq(bcd_hours[0][i])

        # Encoding hours (bits 25-26)
        for i in range(2):
            m.d.comb += time_bits[25 + i].eq(bcd_hours[1][i])

        # Encoding days (bits 30-33)
        for i in range(4):
            m.d.comb += time_bits[30 + i].eq(bcd_days[0][i])

        # Encoding days (bits 35-38)
        for i in range(4):
            m.d.comb += time_bits[35 + i].eq(bcd_days[1][i])

        # Encoding days (bits 40-41)
        for i in range(2):
            m.d.comb += time_bits[40 + i].eq(bcd_days[2][i])

        # Encoding time of day (bits 80-88)
        for i in range(9):
            m.d.comb += time_bits[80 + i].eq(bin_tod[i])

        # Encoding time of day (bits 90-98)
        for i in range(9):
            m.d.comb += time_bits[90 + i].eq(bin_tod[9 + i])

        # Pulse width selection based on bit value
        pulse_width = Signal(range(BIT_DURATION))
        with m.Switch(bit_counter):
            for i in range(100):
                with m.Case(i):
                    with m.If(time_bits[i] == 1):
                        with m.If(i in [0, 9, 19, 29, 39, 49, 59, 69, 79, 89, 99]):
                            m.d.comb += pulse_width.eq(8 * BIT_DURATION // 10)  # 8 ms for 'P'
                        with m.Else():
                            m.d.comb += pulse_width.eq(5 * BIT_DURATION // 10)  # 5 ms for '1'
                    with m.Else():
                        m.d.comb += pulse_width.eq(2 * BIT_DURATION // 10)  # 2 ms for '0'

        # PWM output logic
        m.d.comb += self.pwm_out.eq(bit_clk_counter < pulse_width)

        return m

# Simulation code
if __name__ == "__main__":
    dut = IRIGBEncoder()
    sim = Simulator(dut)

    # Add the clock process
    sim.add_clock(1e-4)  # 1/10 kHz clock period (100 µs)

    def process():
        # Set time information for simulation
        yield dut.set_time.eq(1)
        yield dut.seconds.eq(58)
        yield dut.minutes.eq(59)
        yield dut.hours.eq(23)
        yield dut.days.eq(365)  # 25 May is the 145th day of a non-leap year

        # Release set_time after setting the initial time
        yield Delay(1e-4)  # Wait for one clock cycle
        yield dut.set_time.eq(0)

        # Run enough cycles to cover a complete IRIG-B frame (100 bits)
        for _ in range(5 * 100 * (10_000 // 100)):  # 100 bits, each bit lasts 10^4 / 100 cycles
            yield Delay(1e-4)  # 1/10 kHz clock period (100 µs)

    sim.add_process(process)
    with sim.write_vcd("irigb_pwm.vcd", "irigb_pwm.gtkw"):
        sim.run()

    with open("encode.v", "w") as f:
        f.write(verilog.convert(dut, name="dut", ports=[dut.pwm_out, dut.set_time, dut.seconds, dut.minutes, dut.hours, dut.days]))
