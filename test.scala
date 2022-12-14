package mylib

import spinal.core._
import spinal.sim._
import spinal.core.sim._
import spinal.core.Bool

import scala.util.Random


//MyTopLevel's testbench
object MyPCMSim {
  def main(args: Array[String]) {
    SimConfig.withWave.doSim(new fs_mk){dut =>
      //Fork a process to generate the reset and the clock on the dut
      dut.clockDomain.forkStimulus(period = 200000)

      //val modelState = 0
      var idx = 0
      //synchronize pattern
      var pattern = Array(1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0 , 0)
      val minor = 256 * 8
      val major = minor * 64

      for (idx <- 0 to 999999){
        var x = idx % major
        var y = idx % minor
        if (x >= (major - 24) && x <= (major - 1)) {
          dut.io.nrzl #= pattern(x - (major - 24)) == 0
        }
        else if (y >= (minor - 24) && y <= (minor - 1)) {
          dut.io.nrzl #= pattern(y - (minor - 24)) == 1
        }
        else {
          //Drive the dut inputs with random values
          dut.io.nrzl #= Random.nextBoolean()
        }

        //Wait a rising edge on the clock
        dut.clockDomain.waitFallingEdge()

      }

    }
  }
}
