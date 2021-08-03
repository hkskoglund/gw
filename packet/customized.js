import Packet from "./packet.js";
import Logger from "../logger.js"
import { Protocol, Command } from '../const.js'

class Packet_Customized extends Packet {

    customized = {
        wunderground: {
            id: null,
            key: null,
        },
        hostname: null,
        port: 0,
        interval: 0,
        enabled: false,
        protocol: null,
        path: {
            ecowitt: null,
            wunderground: null
        }
    }

    constructor(cmd, twoBytePacketLength) {

        super(cmd, twoBytePacketLength)

        if (cmd instanceof Buffer) {  // Allow passing of received data and immediate parsing
            this.fromBuffer(cmd);
            this.parse(cmd);
        }

    }

    create(customized)
    // for write customized 0x2b command
    {

        let p = new Packet_Customized(Command.WRITE_CUSTOMIZED);

        this.customized = customized;

        p.writeString(customized.wunderground.id, customized.wunderground.key, customized.hostname)
        p.writeUint16BE(customized.port, customized.interval)
        p.writeUint8(Number(customized.protocol === Protocol.WUNDERGROUND), Number(customized.enabled === true)).writeCRC();

        this.logger.log('log', Logger.level.VERBOSE, 'create_customized_packet', customized, p.toBuffer());

        return p;
    }


    parse_string(data) {
        /*
                0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 39 30 31 32 33 34 35 36 37 38 39 40
              
               ff ff 2a 27 06 74 65 73 74 69 64 07 74 65 73 74 6b 65 79 0e 74 65 73 74 6c 77 75 6e 64 65 72 2e 6e 6f 01 00 02 58 01 01 2b> ��*'testidtestkeytestlwunder.no
                        PL  L  t  e  s  t  i  d  L  t  e  s  t  k  e  y  L  t  e  s t  l  w  u  n  d  e  r  .  n  o| PORT|  UI | P| E| C
               PL 0x27 =   39 (not including preamble ff ff) 
               L = length, P = protocol (0 = ecowitt, 1 = wunderground), E = (0=disabled,1=enable), UI = upload interval 16-600s,C = checksum
              */

        let length_pos = 4,
            end_position,
            eof_string_pos,
            strings = new Array();

        switch (data[2]) {
            case Command.READ_CUSTOMIZED:
                end_position = data.length - 7;

                break;
            case Command.READ_USR_PATH:
                end_position = data.length - 2;
                break;
            default:
                this.logger.log('error', Logger.level.DEBUG, 'Unable to find end_position of string');
                break;
        }

        while (length_pos < end_position) {
            eof_string_pos = length_pos + 1 + data[length_pos];
            strings.push(data.toString('utf8', length_pos + 1, eof_string_pos));
            length_pos = eof_string_pos;

            this.logger.log('log', Logger.level.DEBUG, 'customized string', strings, 'length_pos', length_pos, ' end_position', end_position);
        }

        return strings;

    }


    parse(data) {

        this.fromBuffer(data);
        let strings = this.parse_string(data);

        this.customized.wunderground.id = strings[0];
        this.customized.wunderground.key = strings[1];
        this.customized.hostname = strings[2]
        // https://nodejs.org/api/buffer.html#buffer_buf_readuint16be_offset
        this.customized.port = data.readUInt16BE(data.length - 7);
        this.customized.interval = data.readUInt16BE(data.length - 5);
        this.customized.enabled = data.readUInt8(data.length - 2) == 1 ? true : false;
        this.customized.protocol = data.readUInt8(data.length - 3) == 1 ? Protocol.WUNDERGROUND : Protocol.ECOWITT;

        this.logger.log('log', Logger.level.NORMAL, 'Customized', this.customized);

    }

    get() {
        return this.customized;
    }
}

//https://javascript.info/import-export
export default Packet_Customized;