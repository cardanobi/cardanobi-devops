import fs from 'fs';
import util from 'util';
import stream from 'stream';
import es from 'event-stream';
import { Tail } from 'tail';

export class LogParser {
    constructor(source, template, format) {
        this.source = source;
        this.template = template;
        this.linePattern = new RegExp(format);
        this.tail = undefined;
        this.rowAttributes = [];

        var regex = /\[([^\][]*)]/g, m;
        while ( m = regex.exec(template) ) {
            this.rowAttributes.push(m[1].slice(1));
        }
        console.log("rowAttributes: ", this.rowAttributes);
    }

    read(path, options, callback) {
        if (typeof options === 'function') {
            callback = options;
        }
        // if (typeof options.onEnd === 'function') {
        // 	this.onEnd = options.onEnd;
        // }
        // if (!path || path === '-') {
        //     return this.stdin(callback);
        // } else if (options.tail) {
        //     return this.tail(path, callback);
        // }
        // return this.stream(fs.createReadStream(path), callback);
    
        var s = fs.createReadStream(path)
                    .pipe(es.split())
                    .pipe(es.mapSync(function(line) {
                        // pause the readstream
                        s.pause();
    
                        callback(line);
    
                        // resume the readstream, possibly from a callback
                        s.resume();
                    })
                    .on('error', function(err){
                        console.log('Error while reading the file!', err);
                    })
                    .on('end', function(){
                        console.log('Completed!')
                    })
        );
    }

    stream(path, callback) {
        var options = { fromBeginning: false };
        this.tail = new Tail(path, options);
        this.tail.on('line', function (line) {
            callback(line);
        });  
        this.tail.on("error", function (error) {
            console.log('ERROR: ', error);
        });
    }

    close() {
        if (this.tail) this.tail.unwatch();
    }
}

