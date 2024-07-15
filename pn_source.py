from amaranth import *

class SignalSource(Elaboratable):
    def __init__(self, frame_length=1024):
        self.output = Signal()
        self.frame_start = Signal()
        self.frame_length = frame_length

        self.pn_length = 47
        self.pn_taps = (1 << 46) | (1 << 41) | (1 << 40) | (1 << 39) | 1

        self.sync_code = 0xEB90
        self.sync_length = 16

        # 添加这些信号作为类的属性，以便在仿真中访问
        self.is_sync_phase = Signal()
        self.frame_counter = Signal(range(self.frame_length))

    def elaborate(self, platform):
        m = Module()

        pn_reg = Signal(self.pn_length, reset=1)
        sync_reg = Signal(16, reset=self.sync_code)

        # 帧头标志逻辑
        m.d.comb += self.frame_start.eq(self.frame_counter == 0)

        # 主逻辑
        with m.If(self.is_sync_phase):
            # 输出同步码
            m.d.comb += self.output.eq(sync_reg[-1])
            m.d.sync += [
                sync_reg.eq(Cat(0, sync_reg[:-1])),
                self.frame_counter.eq(self.frame_counter + 1)
            ]
            # 检查是否完成同步码输出
            with m.If(self.frame_counter == self.sync_length - 1):
                m.d.sync += [
                    self.is_sync_phase.eq(0),
                    sync_reg.eq(self.sync_code)  # 重置同步码寄存器
                ]
        with m.Else():
            # 输出PN序列
            m.d.comb += self.output.eq(pn_reg[-1])

            # 计算PN序列的下一位
            feedback = Signal()
            m.d.comb += feedback.eq(pn_reg[-1] ^ pn_reg[-6] ^ pn_reg[-7] ^ pn_reg[-8])

            # 更新PN寄存器和帧计数器
            m.d.sync += [
                pn_reg.eq(Cat(feedback, pn_reg[:-1])),
                self.frame_counter.eq(self.frame_counter + 1)
            ]

        # 检查是否需要开始新的帧
        with m.If(self.frame_counter == self.frame_length - 1):
            m.d.sync += [
                self.frame_counter.eq(0),
                self.is_sync_phase.eq(1),
                sync_reg.eq(self.sync_code)  # 重置同步码寄存器
            ]

        return m


if __name__ == "__main__":
    dut = SignalSource()
    from amaranth.sim import Simulator, Tick

    sim = Simulator(dut)


    def process():
        for _ in range(9999):
            yield Tick()
            output = yield dut.output
            frame_start = yield dut.frame_start
            is_sync = yield dut.is_sync_phase
            frame_count = yield dut.frame_counter
            print(f"Output: {output}, Frame Start: {frame_start}, Is Sync: {is_sync}, Frame Count: {frame_count}")


    sim.add_clock(1e-6)  # 1 MHz clock
    sim.add_sync_process(process)
    with sim.write_vcd("signal_source.vcd"):
        sim.run()
