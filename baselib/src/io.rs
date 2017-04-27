// 0x3007FF8 => BIOSIF
mod RegistersIO {
    ioregs!(LCD = {
            0x4000000 => reg16 DISPCNT {
                0..2 => BGMode {
                    0x1 => Mode1
                    0x2 => Mode2
                    0x3 => Mode3
                    0x4 => Mode4
                    0x5 => Mode5
                },
                3 => Reserved,
                4 => DisplayFrameSelect,
                5 => HBlankIntervalFree,
                6 => OBJCharacterVRAMMapping,
                7 => ForcedBlank,
                8 => ScreenDisplayBG0,
                9 => ScreenDisplayBG1,
                10 => ScreenDisplayBG2,
                11 => ScreenDisplayBG3,
                12 => ScreenDisplayOBJ,
                13 => Window0DisplayFlag,
                14 => Window0DisplayFlag,
                15 => ObjWindowDisplayFlag,
            }

            0x4000002 => reg16 GREENSWAP {
                0 => GreenSwap
            }
        
            0x4000004 => reg16 DISPSTAT {
                0 => VBlankFlag: ro,
                1 => HBlankFlag: ro,
                2 => VCounterFlag: ro,
                3 => VBlankIRQEnable,
                4 => HBlankIRQEnable,
                5 => VCounterIRQEnable,
                8..15 => VCounterSetting
            }

            0x4000006 => reg16 VCOUNT {
                0..7 => CurrentScanline: ro
            }

            0x4000008 => group CNT[4] {
                0x0 => reg16 BG {
                    0..1 => BGPriority,
                    2..3 => CharacterBaseBlock,
                    6 => Mosaic,
                    7 => Palettes
                    8..12 => ScreenBaseBlock,
                    13 => DisplayAreaOverflow,
                    14..15 => ScreenSize
                }
            }

            0x4000010 => group OFFSET[4] {
                0x0 => reg16 X {
                    0..7 => Offset: wo
                }
                0x2 => reg16 Y {
                    0..7 => Offset: wo
                }
            }
            
            0x4000020 => group ROTSCALE[2] {
                0x0 => reg16 DX {
                    0..7 => FractionalPortion: wo,
                    8..14 => IntergerPortion: wo,
                    15 => Sign: wo
                }

                0x2 => reg16 DMX {
                    0..7 => FractionalPortion: wo,
                    8..14 => IntergerPortion: wo,
                    15 => Sign: wo
                }

                0x4 => reg16 DY {
                    0..7 => FractionalPortion: wo,
                    8..14 => IntergerPortion: wo,
                    15 => Sign: wo                    
                }

                0x6 => reg16 DMY {
                    0..7 => FractionalPortion: wo,
                    8..14 => IntergerPortion: wo,
                    15 => Sign: wo                    
                }

                0x8 => reg16 X {
                    0..7 => FractionalPortion: wo,
                    8..14 => IntergerPortion: wo,
                    15 => Sign: wo                    
                }

                0xA => reg16 Y {
                    0..7 => FractionalPortion: wo,
                    8..14 => IntergerPortion: wo,
                    15 => Sign: wo
                }
            }

            0x4000040 => group WINH[2] {
                0x0 => reg8 X2 {
                    0..7 => value: wo
                }

                0x1 => reg8 X1 {
                    0..7 => value: wo
                }
            }

            0x4000040 => group WINV[2] {
                0x0 => reg8 Y2 {
                    0..7 => value: wo
                }

                0x1 => reg8 Y1 {
                    0..7 => value: wo
                }
            }

            0x4000048 => reg16 WININ {
                0 => Window0BG0,
                1 => Window0BG1,
                2 => Window0BG2,
                3 => Window0BG3,
                4 => Window0OBJ,
                5 => Window0SpecialEffet,
                8 => Window1BG0,
                9 => Window1BG1,
                10 => Window1BG2,
                11 => Window1BG3,
                12 => Window1OBJ,
                13 => Window1SpecialEffet,
            }

            0x400004A => reg16 WINOUT {
                0 => OutsideBG0,
                1 => OutsideBG1,
                2 => OutsideBG2,
                3 => OutsideBG3,
                4 => OutsideOBJ,
                5 => OutsideSpecialEffet,
                8 => ObjWindowBG0,
                9 => ObjWindowBG1,
                10 => ObjWindowBG2,
                11 => ObjWindowBG3,
                12 => ObjWindowOBJ,
                13 => ObjWindowSpecialEffet,
            }

            0x400004C => reg16 MOSAIC {
                0..3 => BGMosaicHSize: wo,
                4..7 => BGMosaicVSize: wo,
                8..11 => ObjMosaicHSize: wo,
                12..15 => ObjMosaicVSize: wo,
            }

            0x4000050 => reg16 BLDCNT {
                0 => BG0FirstTargetPixel,
                1 => BG1FirstTargetPixel,
                2 => BG2FirstTargetPixel,
                3 => BG3FirstTargetPixel,
                4 => ObjFirstTargetPixel,
                5 => BDFirstTargetPixel,
                6..7 => ColorSpecialEffect {
                    0 => None,
                    1 => AlphaBlending,
                    2 => BrightnessIncrease,
                    3 => BrightnessDecrease,
                },
                8 => BG0SecondTargetPixel,
                9 => BG1SecondTargetPixel,
                10 => BG2SecondTargetPixel,
                11 => BG3SecondTargetPixel,
                12 => ObjSecondTargetPixel,
                13 => BDSecondTargetPixel,
            }

            0x4000052 => reg16 BLDALPHA {
                0..4 => EVACoefficient: wo,
                8..12 => EVBCoefficient: wo,
            }

            0x4000054 => reg16 BLDY {
                0..4 => EVYCoefficient: wo,
            }
        }
    )

    ioregs!(Sound = {
            0x4000060 => reg16 SOUND1CNT_L {
                0..2 => SweepShift,
                3 => SweepFrequencyDirection
                4..6 => SweepTime,
            }

            0x4000062 => reg16 SOUND1CNT_H {
                0..5 => SoundLength: wo,
                6..7 => WavePaternDuty {
                    0 => WaveEighth,
                    1 => WaveQuarter,
                    2 => WaveHalf,
                    3 => WaveThreeQuarts,
                },
                8..10 => EnvelopeStepTime,
                11 => EnvelopeDirection,
                12..15 => InitialVolumeEnvelope
            }

            0x4000064 => reg16 SOUND1CNT_X {
                0..10 => Frequency: wo,
                14 => LengthFlag,
                15 => Initial: wo,
            }

            0x4000068 => reg16 SOUND2CNT_L {
                0..2 => SweepShift,
                3 => SweepFrequencyDirection
                4..6 => SweepTime,
            }

            0x400006C => reg16 SOUND2CNT_H {
                0..5 => SoundLength: wo,
                6..7 => WavePaternDuty {
                    0 => WaveEighth,
                    1 => WaveQuarter,
                    2 => WaveHalf,
                    3 => WaveThreeQuarts,
                },
                8..10 => EnvelopeStepTime,
                11 => EnvelopeDirection,
                12..15 => InitialVolumeEnvelope            
            }

            0x4000070 => reg16 SOUND3CNT_L {
                5 => WaveRAMDimension,
                6 => WaveRAMBankNumber,
                7 => SoundChannelOff
            }

            0x4000072 => reg16 SOUND3CNT_H {
                0..7 => SoundLength: wo,
                13..14 => SoundVolume {
                    0 => Mute,
                    1 => Full,
                    2 => Half,
                    3 => Quarter,
                },
                15 => ForceVolume {
                    0 => Normal,
                    1 => ForceThreeQuarts,
                }
            }

            0x4000074 => reg16 SOUND3CNT_X {
                0..10 => SampleRate: wo,
                14 => LengthFlag,
                15 => Initial: wo,
            }

            0x4000078 => reg16 SOUND4CNT_L {
                0..5 => SoundLength: wo,
                8..10 => EnvelopeStepTime,
                11 => EnvelopeDirection,
                12..15 => InitialVolumeEnvelope
            }

            0x400007C => reg16 SOUND4CNT_H {
                0..2 => DividingRatioFrequencies: ro,
                3 => CounterStepWidth,
                4..7 => ShiftClockFrequency,
                14 => LengthFlag,
                15 => Initial: wo
            }

            0x4000080 => reg16 SOUNDCNT_L {
                0..2 => SoundMasterVolumeRight,
                4..6 => SoundMasterVolumeLeft,
                8 => Sound1EnableRight,
                9 => Sound2EnableRight,
                10 => Sound3EnableRight,
                11 => Sound4EnableRight,
                12 => Sound1EnableLeft,
                13 => Sound2EnableLeft,
                14 => Sound3EnableLeft,
                15 => Sound4EnableLeft,
            }

            0x4000082 => reg16 SOUNDCNT_H {
                0..1 => SoundVolume {
                    0 => Quarter,
                    1 => Half,
                    2 => Full,
                    3 => Prohibited, 
                },
                2 => DMASoundAVolume,
                3 => DMASoundBVolume,
                8 => DMASoundAEnableRight,
                9 => DMASoundAEnableLeft,
                10 => DMASoundATimerSelect {
                    0 => Timer0,
                    1 => Timer1,
                },
                11 => DMASoundAResetFIFO,
                12 => DMASoundBEnableRight,
                13 => DMASoundBEnableLeft,
                14 => DMASoundBTimerSelect {
                    0 => Timer0,
                    1 => Timer1,
                },
                15 => DMASoundBResetFIFO,
            }

            0x4000084 => reg16 SOUNDCNT_X {
                0 => Sound1ON: ro,
                1 => Sound2ON: ro,
                2 => Sound3ON: ro,
                3 => Sound4ON: ro,
                7 => PSGFIFOMasterEnable
            }

            0x4000088 => reg16 SOUNDBIAS {
                0..9 => BiasLevel,
                14..15 => AmplitudeResolution {
                    0 => NineBit,
                    1 => EightBit,
                    2 => SevenBit,
                    3 => SixBit
                }
            }

            0x4000090 => group WAVE_RAM[4] {
                0x0 => reg16 L {
                    0..15 => value
                }
                0x2 => reg16 H {
                    0..15 => value
                }
            }

            0x40000A0 => group FIFO[2] {
                0x0 => reg8 Data0 {
                    0..7 => data: wo
                }
                0x1 => reg8 Data1 {
                    0..7 => data: wo
                }
                0x2 => reg8 Data2 {
                    0..7 => data: wo
                }
                0x3 => reg8 Data3 {
                    0..7 => data: wo
                }
            }
        }
    )

    ioregs!(DMA = {
            0x40000B0 => group Channel[4] {
                0x0 => reg32 SAD {
                    0..31 => SourceAddress: wo
                }

                0x4 => reg32 DAD {
                    0..31 => DestinationAddress: wo
                }

                0x8 => reg16 CNTL {
                    0..15 => WordCount: wo
                }  

                0xA => reg16 CNTH {
                    5..6 => DestAddrControl {
                        0 => Increment,
                        1 => Decrement,
                        2 => Fixed,
                        3 => IncrementReload
                    },
                    7..8 => SourceAddrControl {
                        0 => Increment,
                        1 => Decrement,
                        2 => Fixed,
                        3 => IncrementReload                    
                    },
                    9 => DMARepeat,
                    10 => DMATransferType,
                    11 => GamePakDRQ,
                    12..13 => DMAStartTiming {
                        0 => Immediately,
                        1 => VBlank,
                        2 => HBlank,
                        3 => Special,
                    },
                    14 => IRQEndWordCount,
                    15 => DMAEnable
                }
            }
    )

    ioregs!(Timer = {
            0x4000100 => group Timer[4] {
                0x0 => reg16 L {
                    0..15 => value
                }

                0x2 => reg16 H {
                    0..1 => Prescaler {
                        0 => F1,
                        1 => F64,
                        2 => F256,
                        3 => F1024
                    }
                    2 => CountUpTiming,
                    6 => TimerIRQEnable,
                    7 => TimerStartStop,
                }
            }
    )

    ioregs!(Serial = {
            0x4000120 => reg32 SIODATA32 {}
            0x4000120 => reg32 SIOMULTI0 {}
            0x4000122 => reg16 SIOMULTI1 {}
            0x4000124 => reg16 SIOMULTI2 {}
            0x4000126 => reg16 SIOMULTI3 {}
            0x4000128 => reg16 SIOCNT {}
            0x400012A => reg16 SIOMLT_SEND {}
            0x400012A => reg16 SIODATA8 {}
            0x4000134 => reg16 RNCT {}
            0x4000140 => reg16 JOYCNT {}
            0x4000150 => reg32 JOY_RECV {}
            0x4000154 => reg32 JOY_TRANS {}
            0x4000158 => reg16 JOYSTAT {}
        }
    )

    ioregs!(KeypadInput = {
            0x4000130 => reg16 KEYINPUT {
                0 => A: ro,
                1 => B: ro,
                2 => Select: ro,
                3 => Start: ro,
                4 => Right: ro,
                5 => Left: ro,
                6 => Up: ro,
                7 => Down: ro,
                8 => R: ro,
                9 => L: ro
            }
            0x4000132 => reg16 KEYCNT {
                0 => A,
                1 => B,
                2 => Select,
                3 => Start,
                4 => Right,
                5 => Left,
                6 => Up,
                7 => Down,
                8 => R,
                9 => L,
                14 => IRQEnableFlag,
                15 => IRQCondition {
                    0 => LogicalOR,
                    1 => LogicalAND,
                }                
            }
        }
    )

    ioregs!(Interrupt = {
            0x4000200 => reg16 IE {
                0 => VBlank,
                1 => HBlank,
                2 => VCounter,
                3 => Timer0,
                4 => Timer1,
                5 => Timer2,
                6 => Timer3,
                7 => SerialCommunication,
                8 => DMA0,
                9 => DMA1,
                10 => DMA2,
                11 => DMA3,
                12 => Keypad,
                13 => GamePak
            }

            0x4000202 => reg16 IF {
                0 => VBlank: set_to_clear,
                1 => HBlank: set_to_clear,
                2 => VCounter: set_to_clear,
                3 => Timer0: set_to_clear,
                4 => Timer1: set_to_clear,
                5 => Timer2: set_to_clear,
                6 => Timer3: set_to_clear,
                7 => SerialCommunication: set_to_clear,
                8 => DMA0: set_to_clear,
                9 => DMA1: set_to_clear,
                10 => DMA2: set_to_clear,
                11 => DMA3: set_to_clear,
                12 => Keypad: set_to_clear,
                13 => GamePak: set_to_clear                
            }

            0x4000204 => reg16 WAITCNT {
                0..1 => SRAMWaitControl {
                    0 => Cycle4,
                    1 => Cycle3,
                    2 => Cycle2,
                    3 => Cycle8
                },
                2..3 => WaitState0FirstAccess {
                    0 => Cycle4,
                    1 => Cycle3,
                    2 => Cycle2,
                    3 => Cycle8                    
                },
                4 => WaitState0SecondAccess {
                    0 => Cycle2,
                    1 => Cycle1
                },
                5..6 => WaitState1FirstAccess {
                    0 => Cycle4,
                    1 => Cycle3,
                    2 => Cycle2,
                    3 => Cycle8                    
                },
                7 => WaitState1SecondAccess {
                    0 => Cycle4,
                    1 => Cycle1
                },
                8..9 => WaitState2FirstAccess {
                    0 => Cycle4,
                    1 => Cycle3,
                    2 => Cycle2,
                    3 => Cycle8                    
                },
                10 => WaitState1SecondAccess {
                    0 => Cycle8,
                    1 => Cycle1
                },
                11..12 => PHITerminalOuput {
                    0 => Disable,
                    1 => Mhz419,
                    2 => Mhz838,
                    3 => Mhz1678
                }
                14 => GamePakPrefetchBuffer,
                15 => GamePakTypeFlag: ro,
            }

            0x4000208 => reg16 IME {
                0 => Enable
            }
        }
    )
}