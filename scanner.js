
import udp from 'dgram'
import { Logger } from './logger.js'
import { Config } from './config.js'

export class Scanner {

    #udpSocket;
    gw;
    #logger;

    constructor() {
        this.gw = {};
        this.#logger = new Logger(Config.log_level);
    }

    start() {
        this.#udpSocket = udp.createSocket('udp4');

        this.#udpSocket.on('listening', () => {
            this.#logger.log('log', Logger.level.NORMAL,Scanner.name + ' listening')

        })

        this.#udpSocket.on('close', () => {
            this.#logger.log('log', Logger.level.NORMAL, Scanner.name + ' closed after ' + Config.discover_delay + ' ms');

        })

        this.#udpSocket.on('message', this.message.bind(this));

        this.#udpSocket.bind(Config.port.BROADCAST);

        if (Config.discover_delay) 
            setTimeout(this.stop.bind(this), Config.discover_delay);

    }

    stop() {
        this.#udpSocket.close();
        if (Object.entries(this.gw).length)
            this.#logger.log('log', Logger.level.NORMAL,this.gw);
    }

    message(msg, rinfo) {
        const d = Date.now();
        let mac,name,ip;

        mac = msg.toString('hex', 5, 11);
        name = msg.toString('utf8', 18, msg.length - 1);
        ip = msg[11].toString() + '.' + msg[12].toString() + '.' + msg[13].toString() + '.' + msg[14].toString();

        if (!this.gw[rinfo.address]) {
           
            this.gw[rinfo.address] = { name: name, mac: mac, ip: ip, rinfo: rinfo, broadcast: msg, lastbroadcast: d };
        }
        else
            this.gw[rinfo.address].lastbroadcast = d;

        this.#logger.log('log', Logger.level.NORMAL,msg, msg.toString('utf8', 18, msg.length - 1), 'MAC: ' + mac + 'IP ' + ip, rinfo);

        //         0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41
        //                                         
        //<Buffer ff ff 12 00 27 48 3f da 55 4d a9 c0 a8 03 cc af c8 17 47 57 31 30 30 30 41 2d 57 49 46 49 34 44 41 39 20 56 31 2e 36 2e 38 09>
        //                       | MAC            |    IP      |CPORT|LL NAME 
        //                                        192.168.3.204|45000|   G  W  1  0  0  0  A  -  W  I  F  I  4  D  A  9     V  1  .  6  .  8
        // CPORT = COMMAND port on gw? af c8 = 45000 dec.
        // WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/SystemFragment.java
        // l. 860 void com.ost.newnettool.Fragment.SystemFragment.writeCMD()
    }

}
