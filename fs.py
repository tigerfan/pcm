from amaranth import *
from amaranth.sim import *
import random

class FS_MK(Elaboratable):
    def __init__(self):
        self.nrzl = Signal()
        self.frame_sync = Signal()
        self.word_sync = Signal()
        self.pcm_data = Signal(8)
        self.sync_locked = Signal()  # 同步锁定指示信号

    def elaborate(self, platform):
        m = Module()

        sync_patt = Const(0xFAF320, 24)
        minor_length = 256 * 8
        patt_length = len(sync_patt)

        # Shift register for PCM stream
        shift_reg = Signal(patt_length)
        m.d.sync += shift_reg.eq(Cat(self.nrzl, shift_reg[:-1]))

        # Correlation with sync pattern
        corr_val = Signal(patt_length)
        for i in range(patt_length):
            with m.If(shift_reg[i] ^ sync_patt[i]):
                m.d.comb += corr_val[i].eq(1)
            with m.Else():
                m.d.comb += corr_val[i].eq(0)

        corr_sum = Signal(range(patt_length + 1))
        m.d.comb += corr_sum.eq(sum(corr_val))

        find_fit = Signal()
        find_anti = Signal()
        find_onerr = Signal()

        m.d.comb += [
            find_fit.eq(corr_sum == 0),
            find_anti.eq(corr_sum == patt_length),
            find_onerr.eq(corr_sum == 1)
        ]

        minor_counter = Signal(13, reset=0)

        m.d.sync += [
            minor_counter.eq(minor_counter + 1)
        ]

        minor_tail = minor_counter >= (minor_length - 1)
        find_patt = find_fit | find_anti | find_onerr

        # State machine for frame synchronizer
        miss_counter = Signal(2)

        with m.FSM() as fsm:
            with m.State("SEARCH"):
                m.d.sync += [
                    minor_counter.eq(0),
                    self.sync_locked.eq(0)
                ]
                with m.If(find_patt):
                    m.d.sync += minor_counter.eq(0)
                    m.next = "CHECK"

            with m.State("CHECK"):
                m.d.sync += minor_counter.eq(minor_counter + 1)
                with m.If(find_fit & minor_tail):
                    m.d.sync += minor_counter.eq(0)
                    m.next = "SYNC"
                with m.Elif(find_fit | minor_tail):
                    m.d.sync += minor_counter.eq(0)

            with m.State("SYNC"):
                m.d.sync += [
                    minor_counter.eq(minor_counter + 1),
                    self.sync_locked.eq(1)  # 设置同步锁定指示信号
                ]
                with m.If(minor_tail):
                    m.d.sync += minor_counter.eq(0)
                with m.If(find_fit & minor_tail):
                    m.d.sync += miss_counter.eq(0)
                with m.Elif(~find_patt & minor_tail):
                    m.d.sync += miss_counter.eq(miss_counter + 1)
                with m.If(miss_counter >= 2):
                    m.d.sync += [
                        miss_counter.eq(0),
                        minor_counter.eq(0)
                    ]
                    m.next = "SEARCH"

        # Frame data buffer
        shift_byte = Signal(8)
        for i in range(8):
            m.d.sync += shift_byte[i].eq(shift_reg[i + patt_length - 8])

        bit2byte = minor_counter % 8 == 0
        with m.If(bit2byte):
            m.d.sync += self.pcm_data.eq(shift_byte)

        m.d.sync += self.frame_sync.eq(find_patt & minor_tail)
        m.d.sync += self.word_sync.eq(self.sync_locked & (minor_counter % 8 == 2))

        return m

def sim_test():
    dut = FS_MK()

    def process():
        # Initialize signals
        yield dut.nrzl.eq(0)
        yield

        # Synchronize pattern
        pattern = [1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0]
        minor = 256 * 8
        major = minor * 64

        for idx in range(1000000):
            x = idx % major
            y = idx % minor
            if major - 24 <= x < major:
                yield dut.nrzl.eq(int(not pattern[x - (major - 24)]))
            elif minor - 24 <= y < minor:
                yield dut.nrzl.eq(pattern[y - (minor - 24)])
            else:
                yield dut.nrzl.eq(random.randint(0, 1))
            # Wait for a falling edge on the clock
            yield

    sim = Simulator(dut)
    sim.add_clock(1e-6, domain="sync")  # 1 MHz clock for sync domain
    sim.add_sync_process(process, domain="sync")
    with sim.write_vcd("mypcm_sim.vcd", "mypcm_sim.gtkw", traces=[dut.nrzl, dut.frame_sync, dut.word_sync, dut.pcm_data, dut.sync_locked]):
        sim.run()

if __name__ == "__main__":
    sim_test()
