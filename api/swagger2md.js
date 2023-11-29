'use strict';

import { CardanoBI } from '../../cardanobi-js/CardanoBI.js';
import * as dotenv from 'dotenv';

dotenv.config();

const CBI = await new CardanoBI({
  apiKey: process.env.CBI_API_KEY,
  apiSecret: process.env.CBI_API_SECRET,
  network:  process.env.CBI_EN
});
import glob from 'glob';
import fs from 'fs';

async function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
  
async function asyncAwaitCaller(controller, functionName, params) {
    let funcArray = []; 
    if (params) {
        funcArray.push(() => controller[functionName](params));
    } else {
        funcArray.push(() => controller[functionName]());
    }
    const response = await Promise.all(funcArray.map(f => f()));
    return response;
}

function getNestedFunction(selectionArray, obj) {
    selectionArray.forEach(key => {
        obj = obj[key];
        // console.log("getNestedFunction: ", JSON.stringify(obj), " , ", key);
    });
    // for (let index = 0; index < selectionArray.length; index++) {
    //     obj = obj[selectionArray[index]];
    // }
    return obj;
}

function getOptionsFromParams(params, path) {
    let options = {};
    params.forEach(pa => {
        let name = pa[1].name;
        let description = pa[1].description;

        if (apiParamsMap[name]) {
            if (typeof apiParamsMap[name] === 'object') {
                let idx = path.lastIndexOf(`{${name}}/`);
                let context = idx > 0 ? path.slice(path.lastIndexOf("/") + 1) : "default";
                options[name] = apiParamsMap[name][context] ? apiParamsMap[name][context] : apiParamsMap[name]["default"];
            } else {
                options[name] = apiParamsMap[name];
            }
        } else {
            console.log("Warning - Missing apiParamsMap entry for: ", name, " | ", description);
        }
    });
    return options;
}

function loadCacheResponse(cbi, out_dir_cache, path, domain, entity, params, isOData) {
    console.log("loadCacheResponse START ", path);
    return new Promise((resolve, reject) => {
        /* determine the api call function */
        let path_suffix = path.substring(path.indexOf(domain)).replaceAll(/\{(.*?)\}/g, "").replace("//","/").replace(/odata(.\/?)/, "");
        if (path_suffix.slice(-1) == "/") path_suffix = path_suffix.substring(0, path_suffix.length - 1);
        let proto = path_suffix.split("/");
        let apiFunc = proto.join(".");

        /* last item in proto is our async function, lets suffix is with _ */
        proto[proto.length - 1] = `${proto[proto.length - 1]}_`;

        let controller = getNestedFunction(proto.slice(0, -1), cbi);
        let funcName = proto.slice(-1)[0];

        let options = getOptionsFromParams(params, path);
        if (isOData) options['odata'] = true;

        let json = "";
        asyncAwaitCaller(controller, funcName, options)
            .then(resp => {
                resolve(resp);
                let cache_file = `${out_dir_cache}/${path.slice(1).replaceAll("/", ".")}`;
                if ((!isOData && Array.isArray(resp[0])) || 
                    (isOData && Array.isArray(resp[0]['value']))) {
                    // Only keep first and last objects
                    let spacerObj = ['...'];
                    if (!isOData)
                        json = JSON.stringify(resp[0].slice(0, 1).concat(spacerObj).concat(resp[0].slice(-1)));
                    else {
                        resp[0]['value'] = resp[0]['value'].slice(0, 1).concat(spacerObj).concat(resp[0]['value'].slice(-1))
                        json = JSON.stringify(resp[0]);
                    }
                } else {
                    json = JSON.stringify(resp[0]);
                }
                fs.appendFileSync(cache_file, json, 'utf8');
            })
            .catch(err => {
                // reject(handleError(err));
                //handleError(err);
                console.log("asyncAwaitCaller error, path:",path,", domain:",domain,", funcName:",funcName," ,options:",options," ,err:",err);
            });
    });
}

function loadResponseFromCache(out_dir_cache, path) {
    let cache_file = `${out_dir_cache}/${path.slice(1).replaceAll("/", ".")}`;
    let rawdata = fs.readFileSync(cache_file);
    return JSON.parse(rawdata);
}

// preprod
// var apiParamsMap = {
//     "Epoch number": 30,
//     "Pool unique identifier": 17,
//     "Pool metadata hash": "ac5fbc53a3d1493b5ba0ea1772fd5d4fda3cd72ba89503ff2261a39052fcd2f5",
//     "Bech32 pool hash": "pool132jxjzyw4awr3s75ltcdx5tv5ecv6m042306l630wqjckhfm32r",
//     "The pool VRF key in HEX format.": "ff9d774cc7e3e85ec1827bfd68c475bc611a9e288e7c9e1fb159fce52d2703fd",
//     "A payment address or a stake address": "stake_test1uqh4cqczjpcjgnd3vhntldk9utmc3754tyrxy9seghptzwc6zayzz",
//     "Stake address": "stake_test1uqh4cqczjpcjgnd3vhntldk9utmc3754tyrxy9seghptzwc6zayzz",
//     "Pool ticker": "ADACT",
//     "The pool update unique identifier": 1,
//     "The Bech32 encoding of a given pool hash": "pool132jxjzyw4awr3s75ltcdx5tv5ecv6m042306l630wqjckhfm32r"
// };

// preprod
var apiParamsMap = {
    "epoch_no": 394,
    "no": 394,
    "pool_id": 4268,
    "meta_hash": "42771b05b30f180890980613b3147f6bb797fe1f8a83e92d39a3135ec9559ea8",
    "pool_hash": "pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc",
    "vrf_key_hash": "9be345bcbcb0cf0559b1135467fd2e4c78c741898cdf8bcb737b2dc5122632df",
    "address": "stake_test1urcfhe8rvzg8t4066nrc43tsj3zdc6tep8uht7gpfjwxmpq6crkjl",
    // "stake_address": "stake_test1urcfhe8rvzg8t4066nrc43tsj3zdc6tep8uht7gpfjwxmpq6crkjl",
    "stake_address": {
        "default": "stake_test1uqh4cqczjpcjgnd3vhntldk9utmc3754tyrxy9seghptzwc6zayzz",
        "delegations": "stake_test1urkmj2vzdey7ac065rleyrc03fzp7gxxhw32pzgxv8dwuasaqtjuz",
        "registrations": "stake_test1urkmj2vzdey7ac065rleyrc03fzp7gxxhw32pzgxv8dwuasaqtjuz",
        "assets": "stake_test1urz84tnkqjx37tqfk02a58yhusajp2qgfyuz5nekqvrm97qdql4ha"
    },
    "ticker": "ADACT",
    "update_id": 1,
    "block_no": 8415364,
    "block_hash": "89ff1090614105a919c9ccc8bb3914aaef1ddd28214a4d55ff65436d2c9fc0b2",
    "slot_no": 85165743,
    "depth": 20,
    "transaction_hash": {
        "default": "5f6f72b00ae982492823fb541153e6c2afc9cb7231687f2a5d82a994f61764a0",
        "utxos": "5f6f72b00ae982492823fb541153e6c2afc9cb7231687f2a5d82a994f61764a0",
        "stake_address_registrations": "13919fc14338f13fa10497293f709f9c12c6275c5b38baa0c60786ffdd51bebb",
        "stake_address_delegations": "e963b50c5a1078f0fbe11c375d047af3a1b2112538ed6cf852809ebbf4dd8440",
        "withdrawals": "cb44c5dd07ab3fee81f05ddd3e4596d2664e6c0ae77bccf99d1c9605dd01808d",
        "treasury": "0bc50b20e16268419048790f6ae3667a1480418dd9faed543bc0e8ca32ea7a08",
        "reserves": "27dff3f43c460e779e35eff505f5f159c4283a8221b31ee17cdcd5b31ad221ba",
        "param_proposals": "62c3c13187423c47f629e6187f36fbd61a9ba1d05d101588340cfbfdf47b22d2",
        "retiring_pools": "0d8eadd3bd58bd1a34641ea4100de509f081fe5dd7ecd33d7da52cbeb8e93494",
        "updating_pools": "37b67370c0e71b6e15d6d5f564a5069461e472a26e6f46a813743458285aef8d",
        "metadata": "6b85afe3fc01c6d3503a5dac8343b56b67f504bb2399deba8b09f8024790b9c4",
        "assetmints": "5f6f72b00ae982492823fb541153e6c2afc9cb7231687f2a5d82a994f61764a0",
        "redeemers": "e584995ed133ae25e5c918d794efa415e10352b0d0e08aa02a196bbd605b9e69",
    },
    "page_no": 1,
    "page_size": 20,
    "order": "desc",
    "fingerprint": {
        "default": "asset1w8wujx5xpxk88u94t0c60lsjlgwpd635a3c3lc",
        "history": "asset1gqp4wdmclgw2tqmkm3nq7jdstvqpesdj3agnel",
        "transactions": "asset1gqp4wdmclgw2tqmkm3nq7jdstvqpesdj3agnel",
        "addresses": "asset1gqp4wdmclgw2tqmkm3nq7jdstvqpesdj3agnel"
    },
    "policy_hash": "706e1c53ed984b016f2c0fc79a450fdb572aa21e4e87d6f74d0b6e8a",
    "poll_hash": "62c6be72bdf0b5b16e37e4f55cf87e46bd1281ee358b25b8006358bf25e71798"
};

// mainnet
// var apiParamsMap = {
//     "epoch_no": 394,
//     "no": 394,
//     "pool_id": 4268,
//     "meta_hash": "42771b05b30f180890980613b3147f6bb797fe1f8a83e92d39a3135ec9559ea8",
//     "pool_hash": "pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc",
//     "vrf_key_hash": "9be345bcbcb0cf0559b1135467fd2e4c78c741898cdf8bcb737b2dc5122632df",
//     "address": "stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma",
//     "stake_address": "stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma",
//     "ticker": "ADACT",
//     "update_id": 1,
//     "block_no": 8415364,
//     "block_hash": "89ff1090614105a919c9ccc8bb3914aaef1ddd28214a4d55ff65436d2c9fc0b2",
//     "slot_no": 85165743,
//     "depth": 20,
//     "transaction_hash": {
//         "default": "5f6f72b00ae982492823fb541153e6c2afc9cb7231687f2a5d82a994f61764a0",
//         "utxos": "5f6f72b00ae982492823fb541153e6c2afc9cb7231687f2a5d82a994f61764a0",
//         "stake_address_registrations": "13919fc14338f13fa10497293f709f9c12c6275c5b38baa0c60786ffdd51bebb",
//         "stake_address_delegations": "e963b50c5a1078f0fbe11c375d047af3a1b2112538ed6cf852809ebbf4dd8440",
//         "withdrawals": "cb44c5dd07ab3fee81f05ddd3e4596d2664e6c0ae77bccf99d1c9605dd01808d",
//         "treasury": "0bc50b20e16268419048790f6ae3667a1480418dd9faed543bc0e8ca32ea7a08",
//         "reserves": "27dff3f43c460e779e35eff505f5f159c4283a8221b31ee17cdcd5b31ad221ba",
//         "param_proposals": "62c3c13187423c47f629e6187f36fbd61a9ba1d05d101588340cfbfdf47b22d2",
//         "retiring_pools": "0d8eadd3bd58bd1a34641ea4100de509f081fe5dd7ecd33d7da52cbeb8e93494",
//         "updating_pools": "37b67370c0e71b6e15d6d5f564a5069461e472a26e6f46a813743458285aef8d",
//         "metadata": "6b85afe3fc01c6d3503a5dac8343b56b67f504bb2399deba8b09f8024790b9c4",
//         "assetmints": "5f6f72b00ae982492823fb541153e6c2afc9cb7231687f2a5d82a994f61764a0",
//         "redeemers": "e584995ed133ae25e5c918d794efa415e10352b0d0e08aa02a196bbd605b9e69",
//     },
//     "page_no": 1,
//     "page_size": 20,
//     "order": "desc",
//     "fingerprint": {
//         "default": "asset1w8wujx5xpxk88u94t0c60lsjlgwpd635a3c3lc",
//         "history": "asset1gqp4wdmclgw2tqmkm3nq7jdstvqpesdj3agnel",
//         "transactions": "asset1gqp4wdmclgw2tqmkm3nq7jdstvqpesdj3agnel",
//         "addresses": "asset1gqp4wdmclgw2tqmkm3nq7jdstvqpesdj3agnel"
//     },
//     "policy_hash": "706e1c53ed984b016f2c0fc79a450fdb572aa21e4e87d6f74d0b6e8a"
// };

// var apiParamsMap = {
//     "Epoch number": 394,
//     "Pool unique identifier": 4268,
//     "Pool metadata hash": "42771b05b30f180890980613b3147f6bb797fe1f8a83e92d39a3135ec9559ea8",
//     "Bech32 pool hash": "pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc",
//     "The pool VRF key in HEX format.": "9be345bcbcb0cf0559b1135467fd2e4c78c741898cdf8bcb737b2dc5122632df",
//     "A payment address or a stake address": "stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma",
//     "Stake address": "stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma",
//     "Pool ticker": "ADACT",
//     "The pool update unique identifier": 1,
//     "The Bech32 encoding of a given pool hash": "pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc",
//     "Block Number": 8415364,
//     "Block number": 8415364,
//     "Block hash": "89ff1090614105a919c9ccc8bb3914aaef1ddd28214a4d55ff65436d2c9fc0b2",
//     "Slot number": 85165743,
//     "Block number to search from - defaults to the latest known block": 8415364,
//     "Number of blocks to return - defaults to 20 - max 100": 20,
//     "Number of blocks to return - defaults to 5 - max 20": 5,
//     "The Bech32 or HEX encoding of the pool hash.": "pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc",
//     "The Bech32 or HEX encoding of the pool hash": "pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc"
// };

function generateNodejsCode(path, domain, entity, params, isOData) {
    let code = "const CBI = await new CardanoBI({ apiKey: 'YOUR-KEY', apiSecret: 'YOUR-SECRET' }); ";

    /* determine the api call function */
    let path_suffix = path.substring(path.indexOf(domain) + domain.length + 1).replaceAll(/\{(.*?)\}/g, "").replace("//","/").replace(/odata(.\/?)/, "");
    if (path_suffix.slice(-1) == "/") path_suffix = path_suffix.substring(0, path_suffix.length - 1);
    let proto = path_suffix.split("/");
    let apiFunc = proto.join(".");

    /* determine the options string */
    let options = {};

    if (isOData) options['odata'] = true;
        
    // params.forEach(p => {
    //     let name = p[1].name;
    //     let description = p[1].description;

    //     options[name] = apiParamsMap[name];
    // });

    params.forEach(pa => {
        let param_value = undefined;
        let name = pa[1].name;
        let description = pa[1].description;
        let scope = pa[1].in;

        // only mandatory params (e.g. in path) are used in code samples
        // in query parameters are optional and therefore not represented in code samples
        if (scope == 'path') {
            if (apiParamsMap[name]) {
                if (typeof apiParamsMap[name] === 'object') {
                    let idx = path.lastIndexOf(`{${name}}/`);
                    let context = idx > 0 ? path.slice(path.lastIndexOf("/") + 1) : "default";
                    // options[name] = apiParamsMap[name][context] ? apiParamsMap[name][context] : "unknown_param";
                    param_value = apiParamsMap[name][context] ? apiParamsMap[name][context] : apiParamsMap[name]["default"];
                } else {
                    // options[name] = apiParamsMap[name];
                    param_value = apiParamsMap[name];
                }
                
                options[name] = param_value;
    
                // if (scope == "path") {
                //     options[name] = param_value;
                // } else if (scope == "query") {
                //     if (options["query"]) {
                //         options["query"] = `${options["query"]}&${name}=${param_value}`;
                //     } else {
                //         options["query"] = `${name}=${param_value}`;
                //     }
                // }
            } else {
                console.log("Warning - Missing apiParamsMap entry for: ", description);
            }
        }

    });

    let varName = proto.slice(-1)[0];
    if ((apiFunc.split(".").length - 1) > 1) varName = `${entity}_${varName}`;
    if (Object.keys(options).length == 0)
        code += `\nconst ${varName} = await CBI.${domain}.${apiFunc}_();`;
    else
        code += `\nconst ${varName} = await CBI.${domain}.${apiFunc}_(${JSON.stringify(options, null, " ").replaceAll("\n", "").replace("}", " }")});`;
    
    params.forEach(pa => {
        let name = pa[1].name;
        code = code.replace(`"${name}"`, `${name}`);
    });
    code = code.replace(`"query"`, `query`);

    code += `\nconsole.log(${varName});`

    console.log(code);
    return code;
}

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

if (!args['file'] || !args['out-dir']) {
    console.log("This script requires input parameters:\nUsages:")
    console.log("\tnode swagger2md.js file={SWAGGER FILE}");
    console.log("\t\t\t out-dir={OUTPUT DIRECTORY}");
    console.log("\t\t\t with-domains (optional)");
    console.log("\t\t\t with-groups (optional)");
    console.log("\t\t\t all-entities (optional)");
    console.log("\t\t\t entities={, separated list of entities} (optional)");
    console.log("\t\t\t groups={, separated list of groups} (optional)");
    console.log("\t\t\t excluded-paths={, separated list of paths} (optional)");
    console.log("\t\t\t included-paths={, separated list of paths} (optional)");
    console.log("\t\t\t debug (optional)");
    process.exit();
}

var file = args['file'];
var outDir = args['out-dir'];
var withDomains = args['with-domains'];
var withGroups = args['with-groups'];
var allEntities = args['all-entities'];
var entities = args['entities'];
var groups = args['groups'];
var excludedPaths = args['excluded-paths'];
var includedPaths = args['included-paths'];
var debug = args['debug'];

if (entities)
    entities = entities.split(",");
else
    entities = [];

if (groups)
    groups = groups.split(",");
else
    groups = [];

if (excludedPaths)
    excludedPaths = excludedPaths.split(",");
else
    excludedPaths = [];

if (includedPaths)
    includedPaths = includedPaths.split(",");
else
    includedPaths = [];

console.log("\nswagger2md.js starting with params: ");
console.log("file: ", file);
console.log("outDir: ", outDir);
console.log("withDomains: ", withDomains);
console.log("withGroups: ", withGroups);
console.log("allEntities: ", allEntities);
console.log("entities: ", entities);
console.log("groups: ", groups);
console.log("excludedPaths: ", excludedPaths);
console.log("includedPaths: ", includedPaths);

// Global Variable
var domainsMap = {
    'core': {
        'short-name': 'core',
        'name': 'Core Domain',
        'dir': 'core-domain',
        'sidebar-position-counter': 0
    },
    'bi': {
        'short-name': 'bi',
        'name': 'BI Domain',
        'dir': 'bi-domain',
        'sidebar-position-counter': 0
    }
}
var base_path = '/api';

try {
    // const fs = require('fs');
    
    let rawdata = fs.readFileSync(file);
    var json = JSON.parse(rawdata);
    // console.log(json.paths);

    let pathObjs = Object.entries(json.paths);
    // console.log(obj);

    let data = "";
    let tocIndex = [];
    let out_dir_cache = outDir + "/cache";

    // Create cache output directory if needed
    if (!fs.existsSync(out_dir_cache)) {
        fs.mkdirSync(out_dir_cache, { recursive: true });
    }
    
    let apiCacheCallsArray = [];
    let apiCacheCallBatchSize = 10;
    let counter = 0, batchCounter = 0;
    apiCacheCallsArray[0] = [];
    // Pre md file generation loop (e.g compute sidebar_position etc, pre-fetch endpoint responses... )
    pathObjs.forEach(p => {
        // Pre-fetch endpoint responses variables
        let responses_file
        // Extracting relevant metadata
        let method_path = p[0];
        let method_type = Object.entries(p[1])[0][0];
        let method_domain = method_path.replace(base_path + "/", "").substring(0, method_path.replace(base_path + "/", "").indexOf("/"));
        let method_domain_dir = domainsMap[method_domain].dir;
        let method_group = p[1][method_type]['tags'][0];
        let method_entity = p[1][method_type]['tags'][0];

        if (p[1][method_type]['tags'] && p[1][method_type]['tags'].length >= 1) {
            method_domain = p[1][method_type]['tags'][0] === undefined ? undefined : p[1][method_type]['tags'][0].toLowerCase();    
            if (p[1][method_type]['tags'][1] && p[1][method_type]['tags'][2]) {
                method_group = p[1][method_type]['tags'][1];    
                method_entity = p[1][method_type]['tags'][2];    
            } else if (p[1][method_type]['tags'][1] && !p[1][method_type]['tags'][2]) {
                method_entity = p[1][method_type]['tags'][1] === undefined ? undefined : p[1][method_type]['tags'][1];    
                method_group = method_entity;
            }
        }
        
        let method_group_dir = method_group;
        let isOData = false;

        if (method_path.includes("odata")) {
            isOData = true;
        }

        if ((allEntities || entities.includes(method_entity) || groups.includes(method_group) || includedPaths.includes(method_path)) && !excludedPaths.includes(method_path)) {
            let method_params = p[1][method_type]['parameters'] === undefined ? [] : Object.entries(p[1][method_type]['parameters']);

            let out_file = outDir + "/" + method_entity + "_main.md";

            // Domain specifics
            let out_dir = outDir;
            if (withDomains) {
                if (withGroups) {
                    if (method_group && method_entity) {
                        out_dir = outDir + "/" + method_domain_dir + "/" + method_group_dir;
                        out_file = out_dir + "/" + method_entity + "_main.md";
                    } else if (!method_group && method_entity) {
                        out_dir = outDir + "/" + method_domain_dir;
                        out_file = out_dir + "/" + method_entity + "_main.md";
                    }
                    
                } else {
                    out_dir = outDir + "/" + method_domain_dir;
                    out_file = out_dir + "/" + method_entity + "_main.md";
                }
            }

            // Fill in the table of content
            if (tocIndex[method_domain] === undefined) tocIndex[method_domain] = [];
            if (!tocIndex[method_domain].includes(out_file)) tocIndex[method_domain].push(out_file);

            // Pre-fetch endpoints responses and save on disk
            if (counter >= apiCacheCallBatchSize) {
                batchCounter++;
                counter = 0;
                apiCacheCallsArray[batchCounter] = [];
            }

            console.log("In scope: ", method_path);
            apiCacheCallsArray[batchCounter].push(() => loadCacheResponse(CBI, out_dir_cache, method_path, method_domain, method_entity.toLowerCase(), method_params, isOData));    
            counter++;

            method_params.forEach(param => {
                if (param[1].description && param[1].description.length > 50) {
                    console.log(`WARNING - Parameter description too long (>50): ${method_path}`);
                }
            });
        }
    });

    // Call all endpoints and wait for all requests to be completed
    for (let index = 0; index < apiCacheCallsArray.length; index++) {
        const response = await Promise.all(apiCacheCallsArray[index].map(f => f()));
        await sleep(2000);
        console.log("Batch ", index + 1, " / ", apiCacheCallsArray.length);
    }
    

    Object.keys(tocIndex).forEach(e => {
        tocIndex[e] = tocIndex[e].sort();
    });
    // console.log("tocIndex:", tocIndex);

    // Actual md file generation loop
    pathObjs.forEach(p => {
        // Extracting relevant metadata
        let method_path = p[0];
        let method_type = Object.entries(p[1])[0][0];
        let method_domain = method_path.replace(base_path + "/", "").substring(0, method_path.replace(base_path + "/", "").indexOf("/"));
        let method_domain_dir = domainsMap[method_domain].dir;
        let method_group = p[1][method_type]['tags'][0];
        let method_entity = p[1][method_type]['tags'][0];

        if (p[1][method_type]['tags'] && p[1][method_type]['tags'].length >= 1) {
            method_domain = p[1][method_type]['tags'][0] === undefined ? undefined : p[1][method_type]['tags'][0].toLowerCase();    
            if (p[1][method_type]['tags'][1] && p[1][method_type]['tags'][2]) {
                method_group = p[1][method_type]['tags'][1];    
                method_entity = p[1][method_type]['tags'][2];    
            } else if (p[1][method_type]['tags'][1] && !p[1][method_type]['tags'][2]) {
                method_entity = p[1][method_type]['tags'][1] === undefined ? undefined : p[1][method_type]['tags'][1];    
                method_group = method_entity;
            }
        }
        
        let method_group_dir = method_group;
        let isOData = false;

        if (method_path.includes("odata")) {
            isOData = true;
        }

        if ((allEntities || entities.includes(method_entity) || groups.includes(method_group) || includedPaths.includes(method_path)) && !excludedPaths.includes(method_path)) {
            let method_summary = p[1][method_type]['summary'] === undefined ? "" : p[1][method_type]['summary'];
            let method_summary_clean = method_summary;
            let method_description = p[1][method_type]['description'] === undefined ? "" : p[1][method_type]['description'];
            let method_params = p[1][method_type]['parameters'] === undefined ? [] : Object.entries(p[1][method_type]['parameters']);
            let out_file = outDir + "/" + method_entity + "_main.md";
            let header_file = outDir + "/" + method_entity + "_header.md";
            let method_responses = Object.entries(p[1][method_type]['responses']);

            let mr = method_responses[0]; // assuming response code 200 exists and is first
            let mr_schema_type = mr[1].content === undefined ? undefined : mr[1].content['application/json'].schema.type === undefined ? "single" : mr[1].content['application/json'].schema.type;
            let mr_schema_ref = mr_schema_type === undefined ? undefined : mr_schema_type == "single" ? mr[1].content['application/json'].schema.$ref : mr[1].content['application/json'].schema.items.$ref;
            let mr_schema_entity_name = mr_schema_ref === undefined ? undefined : mr_schema_ref.substr(mr_schema_ref.lastIndexOf('/') + 1);
            let entity_schema = mr_schema_entity_name === undefined ? undefined : Object.entries(json.components.schemas[mr_schema_entity_name]['properties']);

            // Domain specifics
            let out_dir = outDir;
            if (withDomains) {
                if (withGroups) {
                    if (method_group && method_entity) {
                        out_dir = outDir + "/" + method_domain_dir + "/" + method_group_dir;
                        out_file = out_dir + "/" + method_entity + "_main.md";
                        header_file = out_dir + "/" + method_entity + "_header.md";
                    } else if (!method_group && method_entity) {
                        out_dir = outDir + "/" + method_domain_dir;
                        out_file = out_dir + "/" + method_entity + "_main.md";
                        header_file = out_dir + "/" + method_entity + "_header.md";
                    }
                    
                } else {
                    out_dir = outDir + "/" + method_domain_dir;
                    out_file = out_dir + "/" + method_entity + "_main.md";
                    header_file = out_dir + "/" + method_entity + "_header.md";
                }
            }

            console.log("\nProcessing ", p[0]);
            console.log("Domain: ", method_domain);
            console.log("Group: ", method_group);
            console.log("Entity: ", method_entity);
            console.log("Output Directory: ", out_dir);
            console.log("Main File: ", out_file);
            console.log("Header File: ", header_file);
            console.log(Object.entries(p));
            
            // Create output directory if needed
            if (!fs.existsSync(out_dir)) {
                fs.mkdirSync(out_dir, { recursive: true });
            }
            
            // Formatting
            method_type = method_type.toUpperCase();
            if (method_summary_clean.endsWith("."))
                method_summary_clean = method_summary_clean.substring(0, method_summary_clean.length - 1);

            if (debug) {
                console.log("method_path: ", method_path);
                console.log("method_type: ", method_type);
                console.log("method_domain: ", method_domain);
                console.log("method_group: ", method_group);
                console.log("method_entity: ", method_entity);
                console.log("method_summary: ", method_summary);
                console.log("method_description: ", method_description);
                console.log("method_responses: ", method_responses);
                console.log("entity_schema: ", entity_schema);
                console.log("method_domain_dir: ", method_domain_dir);
                console.log("out_file: ", out_file);
            }

            // Preparing Header File
            if (!fs.existsSync(header_file)) {
                // Determining the sidebar-position
                // let sidebar_position = domainsMap[method_domain]['sidebar-position-counter'] + 1;
                // domainsMap[method_domain]['sidebar-position-counter'] = sidebar_position;
                // console.log("Sidebar Position: ", sidebar_position);

                let sidebar_position = tocIndex[method_domain].indexOf(out_file) + 1;
                console.log("Sidebar Position: ", sidebar_position);

                // sidebar_position: ' + sidebar_position + ' \n\

                data = '--- \n\
title: \'\' \n\
sidebar_label: \'' + method_entity + '\' \n\
--- \n\
import styles from \'@site/src/components/HomepageFeatures/styles.module.css\'; \n\
import Tabs from \'@theme/Tabs\'; \n\
import TabItem from \'@theme/TabItem\'; \n\
import EndpointBadge from \'@site/src/components/EndpointBadge\'; \n\
import ODataBadge from \'@site/src/components/ODataBadge\'; \n\
\n\
<span class="theme-doc-version-badge badge badge--primary">Version: 1.0</span> \n\
\n\
:::tip Endpoints Summary \n\
';
                fs.appendFileSync(header_file, data, 'utf8');
            }
            
            // Parsing Header - Method
            if (!isOData)
                data = '\n<EndpointBadge type="' + method_type + '"/> ' + method_summary_clean+'<br/>';
            else
                data = '\n<EndpointBadge type="' + method_type + '"/> ' + method_summary_clean + ' <ODataBadge/><br/>';
            fs.appendFileSync(header_file, data, 'utf8');

            // Parsing - Method
            let badge_class = "badge--success";
            if (method_type == "post")
                badge_class = "badge--warning";
            
            if (!isOData)
                data = '\n## <span class="theme-doc-version-badge badge ' + badge_class + '">' + method_type + '</span> ' + method_summary_clean;
            else
                data = '\n## <span class="theme-doc-version-badge badge ' + badge_class + '">' + method_type + '</span> ' + method_summary_clean + ' <span class="theme-doc-version-badge badge badge-odata"> OData</span>';

            fs.appendFileSync(out_file, data, 'utf8');

            data = '\n\n' + method_description.replace(method_entity, '_`' + method_entity+'`_');
            fs.appendFileSync(out_file, data, 'utf8');

            data = '\n\n`' + method_type + ' ' + method_path + '`';
            fs.appendFileSync(out_file, data, 'utf8');

            // Parsing - Parameters
            if (method_params.length > 0) {
                data = '\n\n### 🎰 Parameters \n\
\n\
';
                fs.appendFileSync(out_file, data, 'utf8');
    
                data = '|Name|Description|In|Type|Required| \n\
|---|---|---|---|---|\n';
                fs.appendFileSync(out_file, data, 'utf8');
    
                method_params.forEach(param => {
                    let required = param[1].required ? param[1].required : "false";
                    data = '| ' + param[1].name + '|' + param[1].description + '|' + param[1].in + '|' + param[1].schema.type + '|' + required + '|\n';
                    fs.appendFileSync(out_file, data, 'utf8');
                });
            }

            // Parsing - Code samples
            let codeNodejs = generateNodejsCode(method_path, method_domain, method_entity.toLowerCase(), method_params, isOData);

            data = '\n\n### 👨‍💻 Code samples \n\
\n\
<Tabs> \n\
<TabItem value="js" label="Node.js"> \n\
\n\
\```js \n\
'+ codeNodejs + ' \n\
\``` \n\
\n\
</TabItem> \n\
<TabItem value="py" label="Python"> \n\
\n\
\```py \n\
import coming.soon 😀 \n\
\``` \n\
\n\
</TabItem> \n\
</Tabs> \n\
';
            fs.appendFileSync(out_file, data, 'utf8');

            // Parsing - Response Codes
            
            // Find response codes in pre-fetch cache on disk
            // let responseFromCache = "";
            let responseFromCache = loadResponseFromCache(out_dir_cache, method_path);

            data = '\n### 💌 Response Codes \n\
\n\
<Tabs groupId="response-type"> \n\
';
            fs.appendFileSync(out_file, data, 'utf8');
    
            method_responses.forEach(mr => {
                let mr_code = mr[0];
                let mr_description = mr[1]['description']; 
                let mr_style_attr = "{{className: styles.green}}";
                let mr_content = mr[1].content;

                let mr_schema_type = mr[1].content === undefined ? undefined : mr[1].content['application/json'].schema.type === undefined ? "single" : mr[1].content['application/json'].schema.type;
                let mr_schema_ref = mr_schema_type === undefined ? undefined : mr_schema_type == "single" ? mr[1].content['application/json'].schema.$ref : mr[1].content['application/json'].schema.items.$ref;
                let mr_schema_entity_name = mr_schema_ref === undefined ? undefined :  mr_schema_ref.substr(mr_schema_ref.lastIndexOf('/') + 1);
                let mr_schema_entity_props = mr_schema_entity_name === undefined ? undefined :  Object.entries(json.components.schemas[mr_schema_entity_name]['properties']);  

                if (mr_code != "200") {
                    mr_style_attr = "{{className: styles.red}}";
                }

                data = '<TabItem value="'+mr_code+'" label="'+mr_code+'" attributes='+mr_style_attr+'> \n\
\n\
';
                fs.appendFileSync(out_file, data, 'utf8');

                data = '`' + mr_description + '`\n\n';
                fs.appendFileSync(out_file, data, 'utf8');
                
                data = '```json\n';
                fs.appendFileSync(out_file, data, 'utf8');

                if (mr_content) {
                    if (responseFromCache) {
                        fs.appendFileSync(out_file, JSON.stringify(responseFromCache, null, " "), 'utf8');
                        fs.appendFileSync(out_file, '\n', 'utf8');
                    } else {
                        let spacer = "";
                        if (mr_schema_type == "array") {
                            spacer = "  ";
                            data = '[ \n\
     { \n\
    ';
                            fs.appendFileSync(out_file, data, 'utf8');
                        } else {
                            data = '[ \n\
    { \n\
    ';
                            fs.appendFileSync(out_file, data, 'utf8');
                        }
        
                        let objLength = mr_schema_entity_props.length;
                        let count = 0;
                        mr_schema_entity_props.forEach(pr => {
                            let value = "0";
                            count++;
                            if (pr[1].format == "date-time") {
                                value = '"2019-08-24T14:15:22Z"';
                            }
                            if (count==objLength)
                                data = spacer + '"' + pr[0] + '": ' + value + '\n';
                            else
                                data = spacer + '"' + pr[0] + '": ' + value + ', \n';
                            fs.appendFileSync(out_file, data, 'utf8');
                        });
                        
        
                        if (mr_schema_type == "array") {
                            data = ' } \n\
    ] \n\
    ';
                            fs.appendFileSync(out_file, data, 'utf8');
                        }       
                    }
                                 
                } else {
                    data = 'Response schema is undefined.\n';
                    fs.appendFileSync(out_file, data, 'utf8');
                }

                data = '``` \n\
</TabItem> \n\
';
                fs.appendFileSync(out_file, data, 'utf8');
            }
            );

            data = '</Tabs>\n';
            fs.appendFileSync(out_file, data, 'utf8');


            // Parsing - Response Schemas
            data = '\n### 💌 Response Schemas \n\
\n\
<Tabs groupId="response-type"> \n\
';
                        fs.appendFileSync(out_file, data, 'utf8');
                
                        method_responses.forEach(mr => {
                            let mr_code = mr[0];
                            let mr_description = mr[1]['description']; 
                            let mr_style_attr = "{{className: styles.green}}";
                            let mr_content = mr[1].content;

                            let mr_schema_type = mr[1].content === undefined ? undefined : mr[1].content['application/json'].schema.type === undefined ? "single" : mr[1].content['application/json'].schema.type;
                            let mr_schema_ref = mr_schema_type === undefined ? undefined : mr_schema_type == "single" ? mr[1].content['application/json'].schema.$ref : mr[1].content['application/json'].schema.items.$ref;
                            let mr_schema_entity_name = mr_schema_ref === undefined ? undefined :  mr_schema_ref.substr(mr_schema_ref.lastIndexOf('/') + 1);
                            let mr_schema_entity_props = mr_schema_entity_name === undefined ? undefined : Object.entries(json.components.schemas[mr_schema_entity_name].properties); 
            
                            if (mr_code != "200") {
                                mr_style_attr = "{{className: styles.red}}";
                            }
            
                            data = '<TabItem value="'+mr_code+'" label="'+mr_code+'" attributes='+mr_style_attr+'>\n';
                            fs.appendFileSync(out_file, data, 'utf8');
            
                            data = '\nStatus Code **' + mr_code + '**\n\n';

                            fs.appendFileSync(out_file, data, 'utf8');
                            
                            data = '|Name|Type|Description| \n\
|---|---|---|\n';
                            fs.appendFileSync(out_file, data, 'utf8');
            
                            let sub_refs = [];
                            if (mr_content) {
                                mr_schema_entity_props.forEach(pr => {
                                    let pr_name = pr[0];
                                    let pr_type = pr[1].type;
                                    let pr_format = pr[1].format;
                                    let pr_description = pr[1].description;
                                    let pr_sub_ref = pr[1].$ref;

                                    // attribute of simple type
                                    if (pr_sub_ref === undefined) {
                                        if (pr_format === undefined)
                                            data = '| ' + pr_name + '|' + pr_type + '|' + pr_description + '|\n';
                                        else
                                            data = '| ' + pr_name + '|' + pr_type + '(' + pr_format + ')|' + pr_description + '|\n';
                                        fs.appendFileSync(out_file, data, 'utf8');
                                    } else {
                                        // attribute of complex type which will be presented as a sub schema
                                        let pr_sub_name = pr_sub_ref.substring(21);
                                        sub_refs.push(pr_sub_name);

                                        data = '| ' + pr_name + '|' + pr_sub_name + '|' + pr_description + '|\n';
                                        fs.appendFileSync(out_file, data, 'utf8');
                                    }
                                });

                                // sub schema level 1
                                let sub_refs2 = [];
                                for (let i = 0; i < sub_refs.length; i++) {
                                    let sub_schema_name = sub_refs[i];
                                    let sub_schema_entity_props = Object.entries(json.components.schemas[sub_schema_name].properties); 

                                    data = '\n'+sub_schema_name+'\n\n';
                                    fs.appendFileSync(out_file, data, 'utf8');

                                    data = '|Name|Type|Description| \n\
|---|---|---|\n';
                                    fs.appendFileSync(out_file, data, 'utf8');

                                    sub_schema_entity_props.forEach(pr => {
                                        let pr_name = pr[0];
                                        let pr_type = pr[1].type;
                                        let pr_format = pr[1].format;
                                        let pr_description = pr[1].description;
                                        let pr_sub_ref = pr[1].$ref;
    
                                        // attribute of simple type
                                        if (pr_sub_ref === undefined) {
                                            if (pr_format === undefined)
                                                data = '| ' + pr_name + '|' + pr_type + '|' + pr_description + '|\n';
                                            else
                                                data = '| ' + pr_name + '|' + pr_type + '(' + pr_format + ')|' + pr_description + '|\n';
                                            fs.appendFileSync(out_file, data, 'utf8');
                                        } else {
                                            // attribute of complex type which will be presented as a sub schema
                                            let pr_sub_name = pr_sub_ref.substring(21);
                                            sub_refs2.push(pr_sub_name);
    
                                            data = '| ' + pr_name + '|' + pr_sub_name + '|' + pr_description + '|\n';
                                            fs.appendFileSync(out_file, data, 'utf8');
                                        }
                                    });
                                }

                                // sub schema level 2
                                let sub_refs3 = [];
                                for (let i = 0; i < sub_refs2.length; i++) {
                                    let sub_schema_name = sub_refs2[i];
                                    let sub_schema_entity_props = Object.entries(json.components.schemas[sub_schema_name].properties); 

                                    data = '\n'+sub_schema_name+'\n\n';
                                    fs.appendFileSync(out_file, data, 'utf8');

                                    data = '|Name|Type|Description| \n\
|---|---|---|\n';
                                    fs.appendFileSync(out_file, data, 'utf8');

                                    sub_schema_entity_props.forEach(pr => {
                                        let pr_name = pr[0];
                                        let pr_type = pr[1].type;
                                        let pr_format = pr[1].format;
                                        let pr_description = pr[1].description;
                                        let pr_sub_ref = pr[1].$ref;
    
                                        // attribute of simple type
                                        if (pr_sub_ref === undefined) {
                                            if (pr_format === undefined)
                                                data = '| ' + pr_name + '|' + pr_type + '|' + pr_description + '|\n';
                                            else
                                                data = '| ' + pr_name + '|' + pr_type + '(' + pr_format + ')|' + pr_description + '|\n';
                                            fs.appendFileSync(out_file, data, 'utf8');
                                        } else {
                                            // attribute of complex type which will be presented as a sub schema
                                            let pr_sub_name = pr_sub_ref.substring(21);
                                            sub_refs2.push(pr_sub_name);
    
                                            data = '| ' + pr_name + '|' + pr_sub_name + '|' + pr_description + '|\n';
                                            fs.appendFileSync(out_file, data, 'utf8');
                                        }
                                    });
                                }
                                                
                            } else {
                                data = 'Response schema is undefined.\n';
                                fs.appendFileSync(out_file, data, 'utf8');
                            }
            
                            data = '</TabItem> \n';
                            fs.appendFileSync(out_file, data, 'utf8');
                        }
                        );
            
                        data = '</Tabs>\n';
                        fs.appendFileSync(out_file, data, 'utf8');



        } //if - pathObjs
    }); //pathObjs


    // Finalize Headers
    let pattern = outDir + '/**/*_header.md';
    glob.sync(pattern).forEach(f => {
        if (debug) console.log("Finalizing: ", f);
        data = '\n\n:::';
        fs.appendFileSync(f, data, 'utf8');
    });

    // Merge Main & Header files
    glob.sync(pattern).forEach(f => {
        let header_file = f;
        let main_file = header_file.replace("_header.md", "_main.md");
        let target_file = header_file.replace("_header.md", ".md");

        if (!fs.existsSync(main_file)) {
            console.log("Missing file: ", main_file);
        } else {
            if (debug) console.log("Merging files: ", main_file, header_file, " into: ", target_file);
            console.log("Merging files: ", main_file, header_file, " into: ", target_file);

            // open target file for appending
            var w = fs.createWriteStream(target_file, {flags: 'a'});
            // open header file for reading
            var r = fs.createReadStream(header_file);

            w.on('close', function() {
                if (debug) console.log("done writing header");
            });

            r.pipe(w);

            // open main file for reading
            var r = fs.createReadStream(main_file);

            w.on('close', function() {
                if (debug) console.log("done writing main");

                // Cleaning _main and _header files
                if (!debug) {
                    fs.unlinkSync(main_file);
                    fs.unlinkSync(header_file);
                }
            });

            r.pipe(w);
        }
    });
} catch (e) {
    console.log("An error occured:", e);
}

