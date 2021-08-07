const Protocol = {
    ECOWITT : 'ecowitt',
    WUNDERGROUND : 'wunderground'
}

 const CommandResult = {
    SUCCESS : 0x00,
    FAIL : 0x01
}

 const Command = {
    BROADCAST: 0x12,        // 18
    LIVEDATA: 0x27,        // 39
    READ_MAC: 0x26,           // 38
    READ_VER: 0x50,           // 80
    READ_USR_PATH: 0x51,      // 81 
    WRITE_USR_PATH: 0x52,   // 82   
    READ_CUSTOMIZED: 0x2A,   // 42
    WRITE_CUSTOMIZED: 0x2B, // 43
    READ_SYSTEM : 0x30,
    READ_RAIN : 0x34,
    WRITE_REBOOT : 0x40
    //  READ_WUNDERGROUND: 32
}

// System parameter READ_SYSTEM 0x30
const Frequency = {
    RFM433M : 0,
    RFM868M : 1,
    RFM915M : 2,
    RFM920M : 3
}

// System parameter READ_SYSTEM 0x30
const Sensor_Type = {
    WH24 : 0,
    WH65 : 1
}

export {Command,Protocol,CommandResult, Frequency , Sensor_Type}
