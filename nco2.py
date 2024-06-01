from amaranth import *
from amaranth.sim import Simulator


class SimplifiedPLL(Elaboratable):
    def __init__(self, domain_freq):
        self.domain_freq = domain_freq

        # 输入信号
        self.in_clk = Signal()
        # 输出信号
        self.out_clk = Signal()
        self.locked = Signal()

    def elaborate(self, platform):
        m = Module()

        # --- 边沿检测 ---
        last_in_clk = Signal()
        m.d.sync += last_in_clk.eq(self.in_clk)
        rising_edge = self.in_clk & ~last_in_clk

        # --- 频率估计 ---
        period_count = Signal(range(2 ** 16))  # 假设最大周期计数为 2^16
        with m.If(rising_edge):
            m.d.sync += period_count.eq(0)
        with m.Else():
            m.d.sync += period_count.eq(period_count + 1)

        freq_estimate = Signal(32)
        m.d.comb += freq_estimate.eq(self.domain_freq // (period_count + 1))

        freq_estimate_phase = Signal(32)
        with m.If(rising_edge):
            m.d.sync += freq_estimate_phase.eq(2 ** 32 * freq_estimate // self.domain_freq)

        # --- 相位累加器 ---
        phase_acc = Signal(32)
        with m.If(rising_edge):
            m.d.sync += phase_acc.eq(0)
        with m.Else():
            m.d.sync += phase_acc.eq(phase_acc + freq_estimate_phase)

        # --- 输出时钟生成 ---
        m.d.comb += self.out_clk.eq(~phase_acc[-1])

        # --- 锁定检测 ---

        return m


if __name__ == "__main__":
    # --- 测试代码 ---
    dut = SimplifiedPLL(domain_freq=100_000_000)
    sim = Simulator(dut)
    sim.add_clock(1 / 100_000_000)  # 100MHz 时钟


    def process():
        for i in range(10000):
            yield dut.in_clk.eq(i % 100 > 50)
            yield


    sim.add_sync_process(process)
    with sim.write_vcd("simplified_pll.vcd", "simplified_pll.gtkw"):
        sim.run()
