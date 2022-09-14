package zdxrlib

import spinal.core._
import spinal.sim._
import spinal.core.sim._
import spinal.core.Bool

import scala.util.Random


//MyTopLevel's testbench
object MyTopLevelSim {
  def main(args: Array[String]) {
    SimConfig.withWave.doSim(new pcm){dut =>
      //Fork a process to generate the reset and the clock on the dut
      dut.clockDomain.forkStimulus(period = 1000)

      var modelState = 0

      for (idx <- 0 to 9999){
        if (idx%256 == 240) {
          dut.io.nrzl(0) #= true
        }
        else if (idx%256 == 241) {
          dut.io.nrzl(0) #= true
        }
        else if (idx%256 == 242) {
          dut.io.nrzl(0) #= true
        }
        else if (idx%256 == 243) {
          dut.io.nrzl(0) #= false
        }
        else if (idx%256 == 244) {
          dut.io.nrzl(0) #= true
        }
        else if (idx%256 == 245) {
          dut.io.nrzl(0) #= false
        }
        else if (idx%256 == 246) {
          dut.io.nrzl(0) #= true
        }
        else if (idx%256 == 247) {
          dut.io.nrzl(0) #= true
        }
        else if (idx%256 == 248) {
          dut.io.nrzl(0) #= true
        }
        else if (idx%256 == 249) {
          dut.io.nrzl(0) #= false
        }
        else if (idx%256 == 250) {
          dut.io.nrzl(0) #= false
        }
        else if (idx%256 == 251) {
          dut.io.nrzl(0) #= true
        }
        else if (idx%256 == 252) {
          dut.io.nrzl(0) #= false
        }
        else if (idx%256 == 253) {
          dut.io.nrzl(0) #= false
        }
        else if (idx%256 == 254) {
          dut.io.nrzl(0) #= false
        }
        else if (idx%256 == 255) {
          dut.io.nrzl(0) #= false
        }
        else {
          //Drive the dut inputs with random values
          dut.io.nrzl(0) #= Random.nextBoolean()
        }

        //Wait a rising edge on the clock
        dut.clockDomain.waitFallingEdge()

      }
    }
  }
}
