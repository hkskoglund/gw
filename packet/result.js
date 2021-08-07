import Packet from "./packet.js";
import Logger from "../logger.js"
import { CommandResult } from '../const.js'
import GW  from '../gw.js'

class Packet_Result extends Packet {

    constructor(cmd, twoBytePacketLength) {
        super(cmd, twoBytePacketLength)
        if (cmd instanceof Buffer) {  // Allow passing of received data and immediate parsing
            this.fromBuffer(cmd);
            this.parse(cmd);
        }

    }

   


    parse(data) {
       let cmd = data[2];
        this.result = data[4];

        switch (this.result) {
            case CommandResult.SUCCESS:

                this.logger.log('log', Logger.level.VERBOSE, '  ' + GW.getCommandName(cmd) + ' ' + cmd.toString(16) + ' SUCCESS');
                break;
            case CommandResult.FAIL:
                this.logger.log('log', Logger.level.VERBOSE, '  ' + GW.getCommandName(cmd) + ' ' + +cmd.toString(16) + ' FAIL');
                break;
        }
        
    }


    get() {
        return this.result;
    }

}

export default Packet_Result;