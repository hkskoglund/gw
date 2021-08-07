import Packet from "./packet.js";
import Logger from "../logger.js"
import Converter from '../converter.js'

class Packet_Rain extends Packet {

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
       this.rain= {
           rate   : data.readUInt32BE(4),
           day    : data.readUInt32BE(8),
           week   : data.readUInt32BE(12),
           month  : data.readUInt32BE(16),
           year   : data.readUInt32BE(20)
       }

        this.logger.log('log', Logger.level.NORMAL, 'System',this.get());
    }

    get()
    {
        // Convert to mm
        return Converter.dividePropertiesBy10(this.rain);
    }

}

export default Packet_Rain;