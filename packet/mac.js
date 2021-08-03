import Packet from "./packet.js";
import Logger from "../logger.js"
import {Command } from '../const.js'

class Packet_MAC extends Packet {

    constructor(cmd)
    {
        super(cmd);

        if (cmd instanceof Buffer) {  // Allow passing of received data and immediate parsing
            this.fromBuffer(cmd);
            this.parse(cmd);
        }
    }

    parse(data)
    {
        this.mac = data.toString('hex', 4, data.length - 1);

        this.logger.log('log', Logger.level.NORMAL, 'MAC'.padEnd(8), this.mac);
    }

    get()
    {
        return this.mac;
    }

}

export default Packet_MAC;