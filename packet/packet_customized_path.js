import Packet_Customized  from "./packet_customized.js";
import GW from "../gw.js"
import Logger from "../logger.js"

class Packet_Customized_Path extends Packet_Customized {

    constructor(cmd,twoBytePacketLength)
    {
        super(cmd,twoBytePacketLength)
    }

    create(customized) {
       
        this.customized = customized;
 
        let p = (new Packet_Customized_Path(GW.Command.WRITE_USR_PATH)).writeString(customized.path.ecowitt, customized.path.wunderground).writeCRC();

        this.logger.log('log', Logger.level.VERBOSE, 'create Packet_Customized_Path', this.customized, p.toBuffer());

        return p;

    }

    parse(data)
    {
        let paths;

        this.fromBuffer(data);
        super.parse_string(data);
        
        paths = this.parse_string(data);
        this.customized.path.ecowitt = paths[0];
        if (paths[1] != undefined)
            this.customized.path.wunderground = paths[1];
        else
            this.customized.path.wunderground = '';


        this.logger.log('log', Logger.level.NORMAL, 'Ecowitt path'.padEnd(19) + this.customized.path.ecowitt + '\n' + 'Wunderground path'.padEnd(19) + this.customized.path.wunderground);

    }


    get()
    {
        return this.customized.path;
    }

}

export default Packet_Customized_Path;