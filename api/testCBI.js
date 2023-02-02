'use strict'
// const { default: CardanoBI } = import('../../../cardanobi-js/CardanoBI.js');
import { CardanoBI } from '../../../cardanobi-js/CardanoBI.js';

const CBI = await new CardanoBI({ apiKey: "client_auto_2", apiSecret: "secret", network: "preprod" });

import glob from 'glob';
import fs from 'fs';

async function myTest() {
    let funcArray = [];
    let myObj = CBI;
    myObj = myObj['core'];
    funcArray.push(() => myObj["epochs_"]());
    // funcArray.push(() => myObj["epochs_"]());
    const response = await Promise.all(funcArray.map(f => f()));
    return response;
    // console.log(response);
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
    });
    return obj;
}

async function getResponse(apiClient, callParamsArray) {
    let controller = getNestedFunction(callParamsArray.slice(0, -2), apiClient);
    const res = await asyncAwaitCaller(controller, callParamsArray.slice(-2)[0], callParamsArray.slice(-1)[0]);
    return res;
}

function getResponseSync(apiClient, callParamsArray) {
    return new Promise((resolve, reject) => {
        let controller = getNestedFunction(callParamsArray.slice(0, -2), apiClient);
        asyncAwaitCaller(controller, callParamsArray.slice(-2)[0], callParamsArray.slice(-1)[0])
            .then(resp => {
                resolve(resp);
                console.log("DO SMT HERE:",resp);
            })
            .catch(err => {
                // reject(handleError(err));
                handleError(err);
            });
    });
}

const apiCallsArray = [ ["core", "epochs_", { no: 30 }], ["core", "epochs", "params_", { no: 30 }] ] ;
const out_file = "/tmp/outfile.txt";
let data = "";

try {
    const promises = apiCallsArray.map(call => getResponseSync(CBI, call));
    // const promises = apiCallsArray.map(call => getResponse(CBI, call));
    const responses = await Promise.all(promises);

    apiCallsArray.forEach((call, idx) => {
        
        data = `First Step: ${JSON.stringify(call)}\n`;
        fs.appendFileSync(out_file, data, 'utf8');

        let resp = responses[idx];

        data = `Second Step: ${JSON.stringify(call)} ${JSON.stringify(resp)}\n`;
        fs.appendFileSync(out_file, data, 'utf8');

        console.log("response: ", resp);
    });

    data = "Completed\n";
    fs.appendFileSync(out_file, data, 'utf8');

} catch (e) {
    console.log("An error occured:", e);
}




