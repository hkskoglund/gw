

export class Logger {
    static level = {
        OFF: 0,
        NORMAL: 1,
        VERBOSE: 2,
        DEBUG : 3

    }

    #max_level = Logger.level.OFF;

    constructor(lvl) {
        this.#max_level = lvl;
    }

    log(fd,lvl) {

        if (lvl > this.#max_level)
            return;
        
        if (this.#max_level === Logger.level.DEBUG) {
           // const s = (new Error('Stack')).stack;
           // console.error(s);
           //https://stackoverflow.com/questions/2923858/how-to-print-a-stack-trace-in-node-js
           console.trace('Stack');
        }

         // https://stackoverflow.com/questions/19903841/removing-an-argument-from-arguments-in-javascript
        Array.prototype.shift.apply(arguments); // Remove fd
        Array.prototype.shift.apply(arguments); // Remove lvl

        if (lvl > Logger.level.NORMAL)
          console[fd].apply(this, [Date.now()].concat(Array.from(arguments)));
        else
         console[fd].apply(this, Array.from(arguments));
    }
  
}
