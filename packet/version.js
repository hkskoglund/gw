import Packet from "./packet.js";
import Logger from "../logger.js"
import {Command } from '../const.js'

class Packet_Version extends Packet {

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

        this.version = data.toString('utf8', 5, data.length - 1);

        this.logger.log('log', Logger.level.NORMAL, 'Version '.padEnd(8), this.version);
    }

    get()
    {
        return this.version;
    }

}

export default Packet_Version;