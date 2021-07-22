import { Logger } from './logger.js'
import { Config } from './config.js'

export class Packet {

    #arr
    #buf
    #checksum
    #logger;


    constructor(cmd) {
     
        this.#logger = new Logger(Config.log_level);

        if (cmd === undefined)
          return;

        var tempPacketLength = 0x03;
        this.#arr = [0xff, 0xff, cmd, tempPacketLength]
    }

    writeString() {

        for (let i =0; i< arguments.length;i++) // Allow multiple strings in arguments
        {
            let a = arguments[i];
        
            this.#arr.push(a.length);
            for (let p = 0; p < a.length; p++)
                this.#arr.push(a.charCodeAt(p));
        }

        return this; // Allow chaining
    }

    writeUint16BE(value) {

        for (let i =0; i< arguments.length;i++) // Allow multiple strings in arguments
        {
            let a = arguments[i];
            this.#arr.push((a & 0xFF00) >> 8); // Add MSB - big endian 
            this.#arr.push(a & 0xFF);
        }

        return this;
        
    }

    writeCRC() {
        this.#arr[3] = this.#arr.length - 1; // Update PL
        this.#arr.push(this.checksum());

        this.#buf = Buffer.from(this.#arr);

        this.#logger.log('log', Logger.level.DEBUG,'Packet arr,buf,checksum', this.#arr, this.#buf, this.#checksum);

        return this;
    }

    writeUint8(byte) {

        for (let i =0; i< arguments.length;i++) // Allow multiple strings in arguments
          this.#arr.push(arguments[i]);
        
          return this;
    }

    readUint8(index)
    {
        return this.#arr[index];
    }

    fromBuffer(buf)
    {
        this.#arr = Array.from(buf);
        this.#buf = buf;
        this.checksum(true);
       
        return this;
    }


    toBuffer() {
        return this.#buf;
    }

    isChecksumOK()
    {
        return this.#checksum === this.#arr[this.#arr.length-1];
    }

    getChecksum()
    {
        return this.#checksum;
    }

    getBuffer()
    {
        return this.#buf;
    }

    checksum(hasChecksum) {
        let cs = 0;
        let l;

        if (hasChecksum) 
         l = this.#arr.length-1;
        else
          l = this.#arr.length;


        for (let i = 2; i < l; i++)
            cs += this.#arr[i];

        this.#checksum = cs & 0xff;
     

        return this.#checksum;
    }

}