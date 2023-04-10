import { LogParser } from './logparser.js';
import Client from 'pg/lib/client.js';
import crypto from 'crypto';
import * as dotenv from 'dotenv';

dotenv.config();

const client = new Client({
    host: '127.0.0.1',
    user: process.env.CARDANOBI_ADMIN_USERNAME,
    database: 'cardanobi_admin',
    password: process.env.CARDANOBI_ADMIN_PASSWORD,
    port: 5432,
});

const args = process.argv
    .slice(2)
    .map(arg => arg.split('='))
    .reduce((args, [value, key]) => {
        if (!key)
            args[value] = true;
        else
            args[value] = key;
        return args;
    }, {});
    
var logFile = undefined;

if (!args['logfile']) {
    if (!process.env.CARDANOBI_NGINX_LOG_FILE) {
        console.log("This script requires input parameters:\nUsages:")
        console.log("\tnode nginx-log-parser.js logfile={LOG FILE}");
        console.log("\n\nOr define CARDANOBI_NGINX_LOG_FILE in .env")
        process.exit();
    } else {
        logFile = process.env.CARDANOBI_NGINX_LOG_FILE;
    }
} else {
    logFile = args['logfile'];  
}


const createLogTable = async () => {
    try {
        await client.query(
            `CREATE TABLE IF NOT EXISTS "_nginx_logs_staging" (
                "id" SERIAL PRIMARY KEY,
	            "source" VARCHAR(50) NOT NULL,
	            "time" timestamp NOT NULL,
	            "src_ip" VARCHAR(45) NOT NULL,
	            "dest_ip" VARCHAR(45) NOT NULL,
	            "request" text NOT NULL,
	            "request_length" DECIMAL NOT NULL,
	            "api_key" VARCHAR(64) NOT NULL,
	            "upstream_response_time" DECIMAL NOT NULL,
	            "request_time" DECIMAL NOT NULL,
	            "response_size_bytes" DECIMAL NOT NULL,
                "hash" bytea NOT NULL UNIQUE
            );`);
        return true;
    } catch (error) {
        console.error("createLogTable error:",error.stack);
        return false;
    }
};

const checkTableExists = async (tableName) => {
    try {
        var result = await client.query(
            `SELECT COUNT(1) FROM 
                pg_tables
             WHERE 
             schemaname = 'public' AND 
             tablename  = $1;`, [tableName]);
        return result.rows;
    } catch (error) {
        console.error("checkTableExists error:",error.stack);
        return false;
    }
};

const insertLog = async (line) => {
    try {
        // checking for data type consistency
        if (line.upstream_response_time == '-') {
            line.upstream_response_time = '0';
        }

        var query = `INSERT INTO "_nginx_logs_staging" ("source", "time", "src_ip", "dest_ip", "request", "request_length", "api_key", "upstream_response_time", "request_time", "response_size_bytes", "hash" ) 
        VALUES ('${line.source}', 
            '${line.time_iso8601}', 
            '${line.remote_addr}', 
            '${line.upstream_addr}',
            '${line.request}', 
            ${line.request_length}, 
            '${line.http_client_api_key}',
            ${line.upstream_response_time},
            ${line.request_time},
            ${line.bytes_sent},
            '${line.hash}')`;
        

        console.log(query);

        await client.query(query, (err, res) => {
            if (err) console.log("insertLog error: ",err);
        });
        return true;
    } catch (error) {
        console.error(error.stack);
        return false;
    }
};

const readLog = async (line) => {
    try {
        const query = `SELECT * from _nginx_logs_staging WHERE hash = ('${line.hash}');`;
        // const query = `SELECT * from _nginx_logs_staging WHERE hash = ('7e8337fff80d9092010646b5035a32f0c4f3ad343a5eaa33cc07f2c5759f6a1d');`;
        
        // console.log(query);

        var result = await client.query(query);
        return result.rows;
    } catch (error) {
        console.error(error.stack);
        return false;
    }
};

// open connection 
await client.connect();

// create log table if required
var tableExists = await checkTableExists("_nginx_logs_staging");
if (tableExists[0].count == 0) {
    await createLogTable().then(result => {
        if (result) {
            console.log("Table created");
        } else {
            console.log("Table not created");
        }
    });
} else {
    console.log("Table already exists!");
}

var source = "cardanobi.preprod@20.98.184.3";
var logTemplate = "[$time_iso8601] from [$remote_addr] to [$upstream_addr] ,req: [$request] ,reqLength: [$request_length], ApiKey: [$http_client_api_key] ,upstream_response_time: [$upstream_response_time] ,request_time: [$request_time] ,response_size: [$bytes_sent]";
var logRowValidationRegExp = "(,req.+HTTP.+,ApiKey.+,upstream_response_time.+,response_size)"; 
var parser = new LogParser(source, logTemplate, logRowValidationRegExp);

// initialize and run the initial load (in case entries were missed since the parser was last operational)
parser.read(logFile, async function (row) {
    var match = row.toString().match(parser.linePattern);
    if (match) {
        // console.log(row);

        var regex = /\[([^\][]*)]/g;
        var attributes=[], m;
        while ( m = regex.exec(row) ) {
            attributes.push(m[1]);
        }

        var parsedRow = parser.rowAttributes.reduce((acc, item, i) => {
            acc[item] = attributes[i];
            return acc;
        }, {}); 
        parsedRow['source'] = parser.source;
        parsedRow['hash'] = crypto.createHash('sha256','cardanobi').update(JSON.stringify(parsedRow)).digest('hex');

        // console.log("parsedRow: ", parsedRow);

        var rowExists = await readLog(parsedRow);
        
        if (rowExists.length == 0) {
            console.log("Parser startup...found missed log entry to recover:", row);
            insertLog(parsedRow);    
        }
        
    }
});

// // initialize and run the log file stream
// parser.stream(logFile, function (row) {
//     var match = row.toString().match(parser.linePattern);
//     if (match) {
//         // console.log(row);

//         var regex = /\[([^\][]*)]/g;
//         var attributes=[], m;
//         while ( m = regex.exec(row) ) {
//             attributes.push(m[1]);
//         }

//         var parsedRow = parser.rowAttributes.reduce((acc, item, i) => {
//             acc[item] = attributes[i];
//             return acc;
//         }, {}); 
//         parsedRow['source'] = parser.source;
//         parsedRow['hash'] = crypto.createHash('sha256','cardanobi').update(JSON.stringify(parsedRow)).digest('hex');

//         // console.log("parsedRow: ", parsedRow);

//         insertLog(parsedRow);
//     }
// });

// await client.end().then(r => {
//     // parser.close();    
// });


