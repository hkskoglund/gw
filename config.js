import  Logger  from './logger.js'

 let Config = {
    log: true,
    log_level: Logger.level.VERBOSE,
    port: {
        COMMAND: 45000, // Issue commands - hex port afc8 
        BROADCAST_46000: 46000, // Issue broadcast command to GW
        BROADCAST: 59387  // Broadcast from GW to 255.255.255.255:59387 - listen
    },
    hostname : '10.42.0.1', // Ip 
    hostport : 8000,        // Port for POST customized server messages
    discover_delay: 10000 // Terminate scanning after discover_delay ms
}

export default Config;