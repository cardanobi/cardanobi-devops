import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Calculate __dirname in ES Module
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Check if the Swagger file path is provided as a command line argument
if (process.argv.length < 3) {
    console.error('Usage: node script.js <path_to_swagger_file>');
    process.exit(1);
}

// The third argument is the path to the Swagger file
const apiFilePath = process.argv[2];

// Check if the file exists
if (!fs.existsSync(apiFilePath)) {
    console.error('The file does not exist.');
    process.exit(1);
}

// Read the OpenAPI JSON file
fs.readFile(apiFilePath, { encoding: 'utf8' }, (err, data) => {
    if (err) {
        console.error('Error reading the API file:', err);
        return;
    }

    // Parse the JSON content
    const apiSpec = JSON.parse(data);

    // Initialize structures to hold parsed information
    let coreEndpoints = [];
    let biEndpoints = [];

    // Iterate over the paths to categorize endpoints
    Object.keys(apiSpec.paths).forEach((path) => {
        const methods = apiSpec.paths[path];
        Object.keys(methods).forEach((method) => {
            const endpoint = methods[method];
            const tags = endpoint.tags || [];
            const isOData = path.includes('/odata/');
            const endpointInfo = {
                path,
                method,
                isOData,
                tags: tags,
                operationId: endpoint.operationId,
                parameters: endpoint.parameters || [],
            };

            // Group endpoints by tags (Core, BI)
            if (tags.includes('Core')) {
                coreEndpoints.push(endpointInfo);
            } else if (tags.includes('BI')) {
                biEndpoints.push(endpointInfo);
            }
        });
    });

    // normalizing coreEndpoints
    let entityMethods = { core: {}, bi: {} };

    coreEndpoints.forEach((endpoint) => {
        const cleanSegments = cleanPath(endpoint.path).split('/').filter(Boolean);
        // console.log(cleanSegments);
        const rootDomain = cleanSegments[1]; // Assuming the second segment is the root domain ('core' or 'bi')
        console.log(rootDomain);

        const endpointInfo = {
            name: cleanSegments[cleanSegments.length - 1] + '_',
            path: endpoint.path,
            cleanPath: cleanPath(endpoint.path),
            params: endpoint.parameters.map(p => { return { name: p.name, in: p.in, type: p.schema.type } }),
            hasOData: endpoint.isOData
        };

        // console.log("0: ", JSON.stringify(entityMethods));
        // console.log("1: ", cleanSegments);
        // console.log("2: ", cleanSegments.slice(2));
        insertEndpoint(entityMethods, rootDomain, cleanSegments.slice(2), endpointInfo);
        // console.log("3: ", JSON.stringify(entityMethods));
    });

    biEndpoints.forEach((endpoint) => {
        const cleanSegments = cleanPath(endpoint.path).split('/').filter(Boolean);
        // console.log(cleanSegments);
        const rootDomain = cleanSegments[1]; // Assuming the second segment is the root domain ('core' or 'bi')
        console.log(rootDomain);

        const endpointInfo = {
            name: cleanSegments[cleanSegments.length - 1] + '_',
            path: endpoint.path,
            cleanPath: cleanPath(endpoint.path),
            params: endpoint.parameters.map(p => { return { name: p.name, in: p.in, type: p.schema.type } }),
            hasOData: endpoint.isOData
        };

        // console.log("0: ", JSON.stringify(entityMethods));
        // console.log("1: ", cleanSegments);
        // console.log("2: ", cleanSegments.slice(2));
        insertEndpoint(entityMethods, rootDomain, cleanSegments.slice(2), endpointInfo);
        // console.log("3: ", JSON.stringify(entityMethods));
    });

    console.log(entityMethods);

    // Example: Print out the collected Core endpoints
    // console.log('Core Endpoints:', coreEndpoints);
    // console.log('BI Endpoints:', biEndpoints);

    // Further processing to generate core.rs and bi.rs would go here
    // Handle Core Domain

    // Core Rust SDK file
    const fileName = path.join(__dirname, `core.rs`);
    const code = `use std::collections::HashMap;
use crate::utils::api_client::APIClient;
use crate::utils::misc::ApiResponse;
use crate::utils::misc::ApiClientError;
use crate::utils::misc::get_query_params;
use crate::utils::misc::interpolate_str;
use serde_json::Value;
use reqwest::Error as ReqwestError;
`;
    writeCodeToFile(fileName, code);

    // Core Rust Integration Test file
    const fileNameIntegrationTestTemplate = path.join(__dirname, `integration-test.template.rs`);
    const fileNameIntegrationTest = path.join(__dirname, `integration-test-core.rs`);
    copyFile(fileNameIntegrationTestTemplate, fileNameIntegrationTest);

    generateRustCode(fileName, fileNameIntegrationTest, 'core', entityMethods.core);

    writeCodeToFile(fileNameIntegrationTest, `\n}\n`); // Closing
    
    // Bi Rust SDK file
    const fileNameBI = path.join(__dirname, `bi.rs`);
    const codeBI = `use std::collections::HashMap;
use crate::utils::api_client::APIClient;
use crate::utils::misc::ApiResponse;
use crate::utils::misc::ApiClientError;
use crate::utils::misc::get_query_params;
use crate::utils::misc::interpolate_str;
use serde_json::Value;
use reqwest::Error as ReqwestError;
`;
    writeCodeToFile(fileNameBI, codeBI);

    // Bi Rust Integration Test file
    const fileNameIntegrationTestTemplateBI = path.join(__dirname, `integration-test.template.rs`);
    const fileNameIntegrationTestBI = path.join(__dirname, `integration-test-bi.rs`);
    copyFile(fileNameIntegrationTestTemplateBI, fileNameIntegrationTestBI);

    generateRustCode(fileNameBI, fileNameIntegrationTestBI, 'bi', entityMethods.bi);

    writeCodeToFile(fileNameIntegrationTestBI, `\n}\n`); // Closing
});

// Utility function to capitalize the first letter of a string
function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function cleanPath(path) {
    // Remove in-path parameters and 'odata' segment
    return path.split('/').filter(segment => !segment.startsWith('{') && segment !== 'odata').join('/');
}

function insertEndpoint(entityMethods, domain, cleanSegments, endpointInfo) {
    let currentLevel = entityMethods[domain];

    // Navigate or create the structure for each segment
    for (let i = 0; i < cleanSegments.length - 1; i++) {
        const segment = cleanSegments[i];
        if (!currentLevel[segment]) {
            currentLevel[segment] = {};
        }
        currentLevel = currentLevel[segment];
    }

    // console.log("currentLevel:", currentLevel);
    // Insert the endpoint at the correct position
    const endpointName = cleanSegments[cleanSegments.length - 1];
    if (!currentLevel['endpoints']) {
        currentLevel['endpoints'] = [];
    }

    const existingEndpoint = currentLevel.endpoints.find(ep => ep.name === endpointName);
    if (!existingEndpoint) {
        currentLevel['endpoints'].push(endpointInfo);
    }
    // console.log("endpointName:",endpointName);
    // console.log(currentLevel[endpointName]);
    // currentLevel[endpointName].push(endpointInfo);
}


function writeCodeToFile(fileName, code) {
    fs.appendFile(fileName, code, (err) => {
        if (err) {
            console.error(`Error writing the ${fileName} file:`, err);
        }
    });
}

function copyFile(srcFileName, destFileName) {
    fs.copyFile(srcFileName, destFileName, (err) => {
      if (err) {
        console.log('Error copying file:', err);
      } else {
        console.log(`File copied successfully from ${srcFileName} to ${destFileName}.`);
      }
    });
}
  
const context = {
    "epoch_no": 394,
    "no": 394,
    "pool_id": 4268,
    "meta_hash": "42771b05b30f180890980613b3147f6bb797fe1f8a83e92d39a3135ec9559ea8",
    "pool_hash": "pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc",
    "vrf_key_hash": "9be345bcbcb0cf0559b1135467fd2e4c78c741898cdf8bcb737b2dc5122632df",
    "address": "stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma",
    "stake_address": {
        "default": "stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma",
        "delegations": "stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma",
        "registrations": "stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma",
        "assets": "stake1uyq4f9rye96ywptukdypkdu69gc4sd34hwzd940pxslczhc7n5vyt",
        "withdrawals": "stake1u9frlh9lvpdjva46ge0yc4c8zg5e0d37ch42zyyrzmu2hygnmy4xc",
        "mirs": "stake1uypy44wqjznc5w9ns9gsguz4ta83jekrg9d0wupa7j3zsacwvq5ex",
    },
    "ticker": "ADACT",
    "update_id": 1,
    "block_no": 8931769,
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
    "poll_hash": "96861fe7da8d45ba5db95071ed3889ed1412929f33610636c072a4b5ab550211"
};

// JavaScript function to get a value from the context based on the key name
function getValueFromContext(name, cleanPath) {
    const lastWord = cleanPath.split('/').pop();
    let value = context[name];
    if (typeof value === "object") {
        value = value[lastWord] || value.default;
    }
    // Check if the value is a string and quote it
    if (typeof value === "string") {
        value = `"${value}"`;
    }
    return value;
}

function generateIntegrationTestCode(endpoints) {
    let rustTestCode = "";

    const formatFuncName = (cleanPath) => {
        return 'cbi.' + cleanPath.replace(/^\/api\//, '').replace(/\//g, '.').toLowerCase() + '_';
    };

    const mapTypeToRust = (type) => {
        switch (type) {
            case 'integer':
                return 'i64';  // Assuming i64 is suitable for all integer types in your API
            case 'string':
                return '&str';  // Use &str for string references in arguments
            default:
                return 'String';  // Default to String if unsure
        }
    };

    // Collect all unique path parameters and their types from the entire endpoint group
    let allPathParams = {};
    endpoints.forEach(endpoint => {
        endpoint.params.filter(param => param.in === 'path').forEach(param => {
            allPathParams[param.name] = param.type;
        });
    });

    const createTestFunctionCode = (testName, cleanPath, params = [], allPathParams, odata = false) => {
        const funcName = formatFuncName(cleanPath);
        // Define all parameters including those not being actively tested
        const paramsDefinitions = Object.keys(allPathParams).map(paramName => {
            const param = params.find(p => p.name === paramName);
            const rustType = mapTypeToRust(allPathParams[paramName]);
            const isOptional = rustType === 'i64' || rustType === '&str';
            const defaultValue = isOptional ? 'None' : '""';  // Use appropriate default values
            const value = param ? `Some(${getValueFromContext(param.name, cleanPath)})` : defaultValue;
            return `let ${paramName}: Option<${rustType}> = ${value};`;
        }).join('\n            ');

        const paramList = Object.keys(allPathParams).join(', ');
        const optionsCode = odata ? "{ let mut opts = HashMap::new(); opts.insert(\"odata\", \"true\"); opts }" : "HashMap::new()";

        // Dynamically create the suffix based on params and odata state
        let paramNameSuffix = params.map(param => param.name).join('_');
        paramNameSuffix += (paramNameSuffix && odata) ? '_odata' : (odata ? 'odata' : '');

        return `
    #[async_test]
    async fn ${testName}${paramNameSuffix ? `_${paramNameSuffix}` : ''}() {
        with_context("${testName}${paramNameSuffix ? `_${paramNameSuffix}` : ''}", || async {
            let (api_key, api_secret, network) = get_environment_variable();
            let cbi = initialize_cardanobi(&api_key, &api_secret, &network).await;
            ${paramsDefinitions}
            let result = ${funcName}(${paramList.length > 0 ? `${paramList}, ` : ''}${optionsCode}).await.unwrap_or_else(|e| {
                eprintln!("Error: {:?}", e);
                std::process::exit(1);
            });
            println!("Results: {}", result);
            save_response_to_file(result, "${testName}${paramNameSuffix ? `_${paramNameSuffix}` : ''}");
            Ok(())
        }).await;
    }
`;
    };

    endpoints.forEach(endpoint => {
        const testNameBase = endpoint.cleanPath.split('/').filter(Boolean).join('_').toLowerCase();
        if (endpoint.params.length === 0 && !endpoint.hasOData) {
            rustTestCode += createTestFunctionCode(`test_${testNameBase}_without_parameters`, endpoint.cleanPath, [], allPathParams);
        }
        if (endpoint.params.some(param => param.in === "path") || endpoint.hasOData) {
            const params = endpoint.params.filter(param => param.in === "path");
            rustTestCode += createTestFunctionCode(`test_${testNameBase}_with_specific_params`, endpoint.cleanPath, params, allPathParams, endpoint.hasOData);
        }
    });

    return rustTestCode;
}

function generateMethodCodeSmart(endpoints, parent, depth = 0) {
    let methodName = endpoints[0].name;
    let queryParams = new Set();
    let pathParams = new Set();

    // Collect all unique query and path parameters
    endpoints.forEach(endpoint => {
        endpoint.params.forEach(param => {
            if (param.in === 'path') pathParams.add(param.name);
            if (param.in === 'query') queryParams.add(param.name);
        });
    });

    let indent = ' '.repeat(4 * (depth+1));
    let methodSignatureParts = [`pub async fn ${methodName}(&self`];

    // Collect parameter details and associated paths
    let pathParamsDetails = {};
    endpoints.forEach(endpoint => {
        endpoint.params.filter(p => p.in === 'path').forEach(param => {
            pathParamsDetails[param.name] = pathParamsDetails[param.name] || {type: param.type, paths: new Set()};
            pathParamsDetails[param.name].paths.add(endpoint.path);
        });
    });

    // Generate method signature with option types for path parameters
    let pathParamsString = Object.entries(pathParamsDetails).map(([name, details]) => {
        const rustType = details.type === 'integer' ? 'Option<i64>' : 'Option<&str>';
        return `${name}: ${rustType}`;
    }).join(', ');

    if (pathParamsString) {
        methodSignatureParts.push(', ' + pathParamsString);
    }

    methodSignatureParts.push(", options: HashMap<&str, &str>) -> Result<Value, ApiClientError> {");
    let methodSignature = methodSignatureParts.join('');

    // Allowed query parameters
    let allowedParams = `[${Array.from(queryParams).map(q => `"${q}"`).join(', ')}]`;

    // Path selection logic based on the presence of parameters
    let pathSelectionCode = `let path_template = `;
    if (pathParams.size > 1) {
        pathSelectionCode += `match (${Object.keys(pathParamsDetails).map(name => `${name}.is_some()`).join(', ')}) {`;
        // Generating match arms for each path condition
        let conditions = [];
        endpoints.forEach(endpoint => {
            let condition = Object.keys(pathParamsDetails).map(name => 
                endpoint.path.includes(`{${name}}`) ? "true" : "false"
            ).join(', ');
            if (!conditions.includes(condition)) { // Ensure unique conditions only
                conditions.push(condition);
                pathSelectionCode += `\n${indent}        (${condition}) => "${endpoint.path}",`;
            }
        });
        pathSelectionCode += `
            _ => "${endpoints.find(ep => !ep.hasOData)?.path ?? ''}"
        };`;
    } else if (pathParams.size === 1) {
        const singlePathParam = Object.keys(pathParamsDetails)[0];
        pathSelectionCode += `"${Array.from(pathParamsDetails[singlePathParam].paths)[0]}";`;
    } else {
        pathSelectionCode += `"${endpoints.find(ep => !ep.hasOData)?.path ?? ''}";`;
    }

    let methodCodeLines = [
        methodSignature,
        `${indent}let allowed_params = ${allowedParams};`,
        `${indent}let query_string = get_query_params(&options, &allowed_params);`,
        `${indent}${pathSelectionCode}`
    ];

    // Interpolate path parameters
    let pathParamsConstruction = `${indent}let mut params_map = HashMap::new();`;
    Object.entries(pathParamsDetails).forEach(([name, details]) => {
        const conversion = details.type === 'integer' ? `.map(|v| v.to_string())` : `.map(|v| v.to_string())`;
        pathParamsConstruction += `\n${indent}    params_map.insert("${name}", ${name}${conversion});`;
    });
    methodCodeLines.push(pathParamsConstruction);
    methodCodeLines.push(`${indent}let mut path = interpolate_str(&path_template, &params_map);`);

    // Append query string if not empty
    methodCodeLines.push(`${indent}if !query_string.is_empty() {`);
    methodCodeLines.push(`${indent}    path = format!("{}?{}", path, query_string);`);
    methodCodeLines.push(`${indent}}`);

    methodCodeLines.push(`${indent}self.client.get_private(&path).await`);

    return methodCodeLines.map(line => indent + line).join('\n');
}




function generateClassName(parent, entityName) {
    const segments = parent.split('_'); // Split the parent string by underscore
    const formattedEntityName = entityName.charAt(0).toUpperCase() + entityName.slice(1);

    // Check if the last two segments are identical
    if (segments[segments.length - 2] === segments[segments.length - 1]) {
        const lastSegment = segments[segments.length - 1];
        return lastSegment.charAt(0).toUpperCase() + lastSegment.slice(1) + formattedEntityName;
    }

    // If they are different, concatenate all segments except the first one
    const relevantSegments = segments.slice(1); // Get all segments except the first one
    const concatenatedSegments = relevantSegments
        .map(segment => segment.charAt(0).toUpperCase() + segment.slice(1))
        .join(''); // Capitalize and concatenate

    return concatenatedSegments + formattedEntityName;
}

function generateRustCode(fileName, fileNameIntegrationTest, entityName, entityMethods, parent = "") {

    console.log("\ngenerateRustCode, parent:", parent, " ,entityName:", entityName);

    if (parent === "") parent = entityName;

    let className = generateClassName(parent, entityName);

    let code = `
pub struct ${capitalizeFirstLetter(className)} {
    pub client: APIClient,
`;
    let codeIntegrationTest = "";

    // Dynamically add child entities to the Core struct
    Object.keys(entityMethods).forEach(entity => {
        if (entity != "endpoints") {
            let subClassName = generateClassName(parent, entity);
            code += `    pub ${entity.toLowerCase()}: ${className}${capitalizeFirstLetter(entity)},\n`
        }
    });

    code += "}\n";

    code += `
impl ${capitalizeFirstLetter(className)} {
    pub fn new(client: APIClient) -> Self {
        ${capitalizeFirstLetter(className)} {
            client: client.clone(),`;
    
    // Dynamically add child entities to the Core implementation
    Object.keys(entityMethods).forEach(entity => {
        if (entity != "endpoints") {
            let subClassName = generateClassName(parent, entity);
            code += `\n            ${entity.toLowerCase()}: ${className}${capitalizeFirstLetter(entity)}::new(client.clone()),`
        }
    });

    code += `
        }
    }\n`;

    // Generate endpoint methods for given entityName class
    // Assuming entityMethods.endpoints is an array of endpoint objects
    if (entityMethods.endpoints) {
        console.log("entityMethods.endpoints:", entityMethods.endpoints);
        console.log("parent:", parent," ,entityName:",entityName);
        const endpointsByCleanPath = entityMethods.endpoints.reduce((acc, endpoint) => {
            const { cleanPath } = endpoint;
            if (!acc[cleanPath]) {
                acc[cleanPath] = [];
            }
            acc[cleanPath].push(endpoint);
            return acc;
        }, {});
    
        let needsClosing = false;
        Object.entries(endpointsByCleanPath).forEach(([cleanPath, endpoints]) => {
            needsClosing = true;
            // Use cleanPath to generate method name, or any other logic to determine the method name
            code += generateMethodCodeSmart(endpoints, parent);
            codeIntegrationTest += generateIntegrationTestCode(endpoints, parent);

            code += `\n    }\n`; 
        });
    }

    code += `}\n`;

    // codeIntegrationTest += `\n}\n`; 

    writeCodeToFile(fileName, code);

    writeCodeToFile(fileNameIntegrationTest, codeIntegrationTest);

    console.log("GENERATE ENTITIES CODE");

    // Recursively create child entities classes
    Object.keys(entityMethods).forEach(entity => {
        if (entity != "endpoints") {
            let parent_ = parent === "" ? entityName : `${parent}_${entityName}`;
            generateRustCode(fileName, fileNameIntegrationTest, entity, entityMethods[entity], parent_);
        }
    });
}
