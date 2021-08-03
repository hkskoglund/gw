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
    WRITE_CUSTOMIZED: 0x2B // 43
    //  READ_WUNDERGROUND: 32
}

export {Command,Protocol,CommandResult}
