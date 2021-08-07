import Packet from "./packet.js";
import Logger from "../logger.js"

class Packet_System extends Packet {

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
     //WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/SystemFragment.java
      // See l.520 public void set_setting() 
      // https://stackoverflow.com/questions/8083410/how-can-i-set-the-default-timezone-in-node-js#
      // process.env.TZ='UTC'
      let utc = data.readUInt32BE(6),
          // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/getTimezoneOffset

          date = new Date(utc*1000+(new Date().getTimezoneOffset()*60*1000));
       
       this.system = {
           frequency        : data[4],
           sensor_type      : data[5],
           utc              : utc,
           timestamp        : this.timestamp,
           date             : date,
           recv             : new Date(this.timestamp+(new Date().getTimezoneOffset()*60*1000)),
           diff             : utc*1000-this.timestamp,
           timezone_index   : data[10],  // Seems to index the drop-down timezones in "Device setting" in WS View. Confirmed l. 540 bArr[10] = (byte) this.set_tz.getSelectedItemPosition();
           dst              : (data[11] & 0x01) == 0x01, 
           auto_timezone    : !((data[11] >> 1) == 0x01)           // Bit 2 -> 1 off, 0= on ?!
       }

       this.system.

        this.logger.log('log', Logger.level.NORMAL, 'System', this.system);
    }

    get()
    {
        
        return this.system;
    }

}

export default Packet_System;

// Unix commands :
//  timedatectl
//  chronyc tracking
/*
chronyc tracking
Reference ID    : A29FC801 (time.cloudflare.com)
Stratum         : 4
Ref time (UTC)  : Thu Aug 05 06:52:19 2021
System time     : 0.000339764 seconds slow of NTP time
Last offset     : -0.000208127 seconds
RMS offset      : 0.336752445 seconds
Frequency       : 7.325 ppm slow
Residual freq   : -0.006 ppm
Skew            : 0.104 ppm
Root delay      : 0.033092078 seconds
Root dispersion : 0.000792732 seconds
Update interval : 512.5 seconds
Leap status     : Normal
*/

//  hwclock