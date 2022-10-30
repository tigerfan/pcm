/*
 * PCM frame synchronizer
 */
package mylib

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._

class pcm extends Component {
  val io = new Bundle {
//    val sysClk = in Bool()
    val sysRst = in Bool()

    val bitSync = in Bool()
    val nrzl = in Bool()
    val frameSync = out Bool()
    val isAnti = out Bool()
    val nearCode = out Bool()
    val wordSync = out Bool()
    val pcmData = out UInt (8 bits)

    val sysCD = ClockDomain(bitSync, sysRst, config = ClockDomainConfig(
      clockEdge = RISING,
      resetKind = ASYNC,
      resetActiveLevel = LOW))

    val pcm_mk = sysCD(new fs_mk)

    pcm_mk.io.nrzl := nrzl
    frameSync := pcm_mk.io.frameSync
    isAnti := pcm_mk.io.isAnti
    nearCode := pcm_mk.io.nearCode
    wordSync := pcm_mk.io.wordSync
    pcmData := pcm_mk.io.pcmData

  }
}

class fs_mk extends Component {
  val io = new Bundle {
    val nrzl = in Bool()
    val frameSync = out Bool()
    val isAnti = out Bool()
    val nearCode = out Bool()
    val wordSync = out Bool()
    val pcmData = out UInt (8 bits)
  }

  val synCode = B"24'x??????"
  val frameLength = 256 * 8
  val antiCode = ~synCode
  val codeLength = synCode.getWidth

  //pcm stream put into shift register
  val shiftReg = Vec(Reg(Bool()), codeLength)
  shiftReg(0) := io.nrzl
  for (i <- 1 to codeLength - 1) {
    shiftReg(i) := shiftReg(i - 1)
  }

  //frame data stream "corralate" with synchronize code
  val corrVal = Vec(UInt(5 bits), codeLength)
  for (i <- 0 to codeLength - 1) {
    when (shiftReg(i) ^ synCode(i)) {
      corrVal(i) := U"00001"
    } otherwise {
      corrVal(i) := U"00000"
    }
  }

  val corrSum: UInt = corrVal.reduceBalancedTree(_ + _)

  //allow one difficult
  io.frameSync := corrSum === 0
  io.isAnti := corrSum === codeLength
  io.nearCode := corrSum === 1

  //frame synchronizer with 3-state machine: search, check, synchronize
  val fsm = new StateMachine {
    val frameCounter = Reg(UInt(13 bits)) init (0)
    val missCounter = Reg(UInt(2 bits)) init (0)
    val frameEnd = Bool()
    val findCode = Bool()

    frameEnd := frameCounter === (frameLength - 1)
    findCode := io.frameSync | io.isAnti | io.nearCode

    //searching code
    val stateSearch: State = new State with EntryPoint {
      whenIsActive {
        when(findCode) {
          goto(stateCheck)
        }
      }
    }

    //checking code and length
    val stateCheck: State = new State {
      onEntry(frameCounter := 0)
      whenIsActive {
        frameCounter := frameCounter + 1
        when(io.frameSync & frameEnd) {
          goto(stateSync)
        }
        when(io.frameSync | frameEnd) {
          frameCounter := 0
        }
      }
    }

    //when end of frame can't find code, exit to search state...
    val stateSync: State = new State {
      onEntry(frameCounter := 0)
      whenIsActive {
        frameCounter := frameCounter + 1
        when(frameEnd) {
          frameCounter := 0
        }
        when(frameEnd & findCode) {
          missCounter := 0
        }
        when(frameEnd & ~findCode) {
          missCounter := missCounter + 1
        }
        when(missCounter >= 2) {
          goto(stateSearch)
        }
      }
    }

    io.wordSync := frameCounter % 8 === 0
  }

  //frame data buffer
  var shiftByte = Reg(UInt(8 bits))
  for (i <- 0 to 7) {
    shiftByte(i) := shiftReg(i)
  }

  io.pcmData := RegNextWhen(shiftByte, io.wordSync)


}


//Generate the MyTopLevel's Verilog
object MyPCMVerilog {
  def main(args: Array[String]) {
    SpinalVerilog(new pcm)
  }
}

//Define a custom SpinalHDL configuration with synchronous reset instead of the default asynchronous one. This configuration can be resued everywhere
object MySpinalHDLConfig extends SpinalConfig(defaultConfigForClockDomains = ClockDomainConfig(resetKind = SYNC))

//Generate the MyTopLevel's Verilog using the above custom configuration.
object MyPCMVerilogWithCustomConfig {
  def main(args: Array[String]) {
    MySpinalHDLConfig.generateVerilog(new pcm)
  }
}