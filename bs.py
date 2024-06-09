from amaranth import *
from amaranth.sim import Simulator, Delay
from amaranth.back import verilog
import random

class SimplifiedPLL(Elaboratable):
    def __init__(self, init_freq, domain_freq):
        self.init_freq = init_freq  # PCM码流的码速率
        self.domain_freq = domain_freq  # 系统时钟频率，100MHz

        self.nrzl_in = Signal()  # 输入数据
        self.bs_output = Signal(reset=0)  # 同步输出信号
        self.data_out = Signal(reset=0)  # 判决后的数据输出
        self.locked = Signal(reset=0)  # 锁定指示信号

    def elaborate(self, platform):
        m = Module()

        init_value = int(2 ** 32 * self.init_freq // self.domain_freq)
        phase_acc = Signal(32, reset=0)  # NCO相位累加器

        bs_phase_i = Signal()   # 同相积分支路（早门）
        bs_phase_q = Signal()   # 中相积分支路（迟门）
        early_integrator = Signal(8)
        late_integrator = Signal(8)

        lock_threshold = 3  # 锁定阈值
        lock_counter = Signal(8)
        unlocked = Signal(reset=1)  # 初始状态为未锁定

        # --- 每个码元为一个检测和调整的周期 ---
        last_bs_clk = Signal()
        m.d.sync += last_bs_clk.eq(~self.bs_output)
        rising_edge = ~self.bs_output & ~last_bs_clk

        with m.If(rising_edge):
            with m.If(self.locked):
                with m.If(early_integrator > late_integrator):
                    m.d.sync += phase_acc.eq(phase_acc + 1)
                with m.Elif(early_integrator < late_integrator):
                    m.d.sync += phase_acc.eq(phase_acc - 1)
            with m.Else():
                m.d.sync += phase_acc.eq(phase_acc + (early_integrator - late_integrator) >> 1)
            m.d.sync += early_integrator.eq(0)
            m.d.sync += late_integrator.eq(0)

        # 早门积分器更新
        with m.If(self.nrzl_in & bs_phase_i):
            m.d.sync += early_integrator.eq(early_integrator + 1)

        # 迟门积分器更新
        with m.If(self.nrzl_in & bs_phase_q):
            m.d.sync += late_integrator.eq(late_integrator + 1)

        # --- 相位累加器 ---
        m.d.sync += phase_acc.eq(phase_acc + init_value)

        # --- 输出时钟生成 ---
        m.d.comb += self.bs_output.eq(phase_acc[-1])

        m.d.comb += bs_phase_i.eq(~(phase_acc[-1] & phase_acc[-2]))
        m.d.comb += bs_phase_q.eq(phase_acc[-1] | phase_acc[-2])

        # 码元同步和数据判决
        sample_counter = Signal(8)
        data_buffer = Signal(8)
        m.d.sync += sample_counter.eq(sample_counter + 1)
        with m.If(sample_counter == 45):  # 100MHz/2.2MHz = 45
            m.d.sync += data_buffer.eq(Cat(data_buffer[1:], self.nrzl_in))
            with m.If(data_buffer.bit_select(4, 1)):
                m.d.sync += self.data_out.eq(1)
            with m.Else():
                m.d.sync += self.data_out.eq(0)
            m.d.sync += sample_counter.eq(0)

        # --- 锁定检测 ---
        # 检测锁定状态
        with m.If(early_integrator > late_integrator):
            m.d.sync += lock_counter.eq(lock_counter + 1)
            with m.If(lock_counter > 50):  # 锁定状态
                m.d.sync += unlocked.eq(0)
                m.d.sync += self.locked.eq(1)
        with m.Else():
            m.d.sync += lock_counter.eq(0)
            m.d.sync += unlocked.eq(1)
            m.d.sync += self.locked.eq(0)

        return m


if __name__ == "__main__":
    # --- 测试代码 ---
    dut = SimplifiedPLL(init_freq=2_345_678, domain_freq=100_000_000)
    sim = Simulator(dut)
    sim.add_clock(1 / 100_000_000)  # 100MHz 时钟

    def process():
        random.seed(42)  # 固定随机种子以便于复现
        Delay(200)
        for i in range(10000):  # 增加仿真周期数以观察更多结果
            yield dut.nrzl_in.eq(random.randint(0, 1))
            yield Delay(1 / 2345678)


    sim.add_sync_process(process)
    with sim.write_vcd("simplified_pll.vcd", "simplified_pll.gtkw"):
        sim.run()

    # 输出 Verilog 文件
    with open("simplified_pll.v", "w") as f:
        f.write(verilog.convert(dut, ports=[dut.nrzl_in, dut.bs_output, dut.data_out, dut.locked]))
