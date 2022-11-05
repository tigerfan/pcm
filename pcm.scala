/*
 * PCM frame synchronizer
 */
package mylib

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._
import spinal.core.sim._

class my_pcm extends Component {
  val io = new Bundle {
    val sysRst = in Bool()
    val bitSync = in Bool()
    val nrzl = in Bool()
    val frameSync = out Bool()
    val wordSync = out Bool()
    val pcmData = out UInt (8 bits)
  }

    val sysCD = ClockDomain(io.bitSync, io.sysRst, config = ClockDomainConfig(
      clockEdge = RISING,
      resetKind = ASYNC,
      resetActiveLevel = LOW))

    val pcm_mk = sysCD(new fs_mk)

    pcm_mk.io.nrzl <> io.nrzl
    io.frameSync <> pcm_mk.io.frameSync
    io.wordSync <> pcm_mk.io.wordSync
    io.pcmData <> pcm_mk.io.pcmData

}

class fs_mk extends Component {
  val io = new Bundle {
    val nrzl = in Bool()
    val frameSync = out Bool()
    val wordSync = out Bool()
    val pcmData = out UInt (8 bits)
  }

  val syncPatt = B"24'x??????"
  val minorLength = 256 * 8
  val antiPatt = ~syncPatt
  val pattLength = syncPatt.getWidth

  //pcm stream put into shift register
  val shiftReg = Vec(Reg(Bool()), pattLength)
  shiftReg(0) := io.nrzl
  for (i <- 1 to pattLength - 1) {
    shiftReg(i) := shiftReg(i - 1)
  }

  //frame data stream "corralate" with synchronize pattern
  val corrVal = Vec(UInt(5 bits), pattLength)
  for (i <- 0 to pattLength - 1) {
    when (shiftReg(i) ^ syncPatt(i)) {
      corrVal(i) := U"00001"
    } otherwise {
      corrVal(i) := U"00000"
    }
  }

  val corrSum: UInt = corrVal.reduceBalancedTree(_ + _)

  //allow one difficult
  val findFit = corrSum === 0
  val findAnti = corrSum === pattLength
  val findOnerr = corrSum === 1
  val findPatt = findFit | findAnti | findOnerr

  val minorCounter = Reg(UInt(13 bits)) init (0)
  val minorTail = minorCounter >= (minorLength - 1)
  val whenSync = Bool()

  //frame synchronizer with 3-state machine: search, check, synchronize
  val fsm = new StateMachine {
    whenSync := False
    val missCounter = Reg(UInt(2 bits)) init (0)

    //searching pattern
    val stateSearch: State = new State with EntryPoint {
      onEntry(minorCounter := 0)
      whenIsActive {
        minorCounter := minorCounter + 1
        whenSync := False
        when(findFit) {
          goto(stateCheck)
        }
      }
    }

    //checking pattern and length
    val stateCheck: State = new State {
      onEntry(minorCounter := 0)
      whenIsActive {
        minorCounter := minorCounter + 1
        whenSync := False
        when(findFit & minorTail) {
          goto(stateSync)
        }
        when(findFit | minorTail) {
          minorCounter := 0
        }
      }
    }

    //when end of minor frame can't find pattern, exit to search state...
    val stateSync: State = new State {
      onEntry(minorCounter := 0)
      whenIsActive {
        minorCounter := minorCounter + 1
        whenSync := True
        when(minorTail) {
          minorCounter := 0
        }
        when(findFit & minorTail) {
          missCounter := 0
        }
        when(~findPatt & minorTail) {
          missCounter := missCounter + 1
        }
        when(missCounter >= 2) {
          goto(stateSearch)
        }
      }
      onExit(missCounter := 0)
    }
  }

  //frame data buffer
  var shiftByte = Reg(UInt(8 bits))
  for (i <- 0 to 7) {
    shiftByte(i) := shiftReg(i + (pattLength - 8))
  }

  val bit2byte = minorCounter % 8 === 0
  io.pcmData := RegNextWhen(shiftByte, bit2byte)
  io.frameSync := RegNext(findPatt & minorTail)
  io.wordSync := whenSync & Delay(bit2byte, 2)

}

//Generate the MyTopLevel's Verilog
object MyPCMVerilog {
  def main(args: Array[String]) {
    SpinalVerilog(new my_pcm)
  }
}

//Define a custom SpinalHDL configuration with synchronous reset instead of the default asynchronous one. This configuration can be resued everywhere
object MySpinalHDLConfig extends SpinalConfig(defaultConfigForClockDomains = ClockDomainConfig(resetKind = SYNC))

//Generate the MyTopLevel's Verilog using the above custom configuration.
object MyPCMVerilogWithCustomConfig {
  def main(args: Array[String]) {
    MySpinalHDLConfig.generateVerilog(new my_pcm)
  }
}
