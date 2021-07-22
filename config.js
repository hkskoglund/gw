import { Logger } from './logger.js'

export let Config = {
    log: true,
    log_level: Logger.level.DEBUG,
    port: {
        COMMAND: 45000, // Issue commands - hex port afc8 
        BROADCAST: 59387  // Broadcast to 255.255.255.255:59387 - listen
    },
    discover_delay: 3000
}