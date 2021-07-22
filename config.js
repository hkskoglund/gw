import { Logger } from './logger.js'

export let Config = {
    log: true,
    log_level: Logger.level.NORMAL,
    port: {
        COMMAND: 45000, // Issue commands - hex port afc8 
        BROADCAST: 59387  // Broadcast to 255.255.255.255:59387 - listen
    },
    hostname : '10.42.0.1', // Ip 
    hostport : 8000,        // Port for POST customized server messages
    discover_delay: 3000 // Terminate scanning after discover_delay ms
}