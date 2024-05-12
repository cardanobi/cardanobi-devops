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
            params: endpoint.parameters.map(p => { return { name: p.name, in: p.in } }),
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
            params: endpoint.parameters.map(p => { return { name: p.name, in: p.in } }),
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

    // Further processing to generate core.py and bi.py would go here
    // Handle Core Domain

    // Core Python SDK file
    const fileName = path.join(__dirname, `core.py`);
    let code = `from utils import get_query_params\n\n`;
    writeCodeToFile(fileName, code);

    // Core Python Integration Test file
    const fileNameIntegrationTestTemplate = path.join(__dirname, `integration-test.template.py`);
    const fileNameIntegrationTest = path.join(__dirname, `integration-test-core.py`);
    copyFile(fileNameIntegrationTestTemplate, fileNameIntegrationTest);

    generatePythonCode(fileName, fileNameIntegrationTest, 'core', entityMethods.core);
    
    // Core Python SDK file
    const fileNameBI = path.join(__dirname, `bi.py`);
    let codeBI = `from utils import get_query_params\n\n`;
    writeCodeToFile(fileNameBI, codeBI);

    // Core Python Integration Test file
    const fileNameIntegrationTestTemplateBI = path.join(__dirname, `integration-test.template.py`);
    const fileNameIntegrationTestBI = path.join(__dirname, `integration-test-bi.py`);
    copyFile(fileNameIntegrationTestTemplateBI, fileNameIntegrationTestBI);

    generatePythonCode(fileNameBI, fileNameIntegrationTestBI, 'bi', entityMethods.bi);
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
    let pythonTestCode = "";
  
    const formatFuncName = (cleanPath) => {
      // Remove "/api/" prefix and then replace all "/" with "." to get the hierarchical structure
      return 'CBI.' + cleanPath.replace(/^\/api\//, '').replace(/\//g, '.');
    };
  
    const createTestFunctionCode = (testName, cleanPath, params = [], odata = false) => {
      const funcName = formatFuncName(cleanPath);
      const paramValues = params.map(param => `${param.name}=${getValueFromContext(param.name, cleanPath)}`).join(', ');
      const odataCode = odata ? "odata='true'" : "";
      const allParams = [paramValues, odataCode].filter(param => param).join(', ');
        return `
@pytest.mark.asyncio
async def ${testName}():
    async with my_context("${testName}"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await ${funcName}_${allParams ? `(${allParams})` : '()'}
        await CBI.client.session.close()
        save_response_to_file(response, "${testName}")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  `;
    };
  
    endpoints.forEach(endpoint => {
      const testNameBase = endpoint.cleanPath.split('/').filter(Boolean).join('_');
      if (endpoint.params.length === 0 && !endpoint.hasOData) {
        pythonTestCode += createTestFunctionCode(`test_${testNameBase}_without_parameters`, endpoint.cleanPath);
      }
      if (endpoint.params.some(param => param.in === "path") || endpoint.hasOData) {
        const params = endpoint.params.filter(param => param.in === "path");
        const testNameSuffix = params.length > 0 ? 'with_specific_params' : 'with_odata';
        pythonTestCode += createTestFunctionCode(`test_${testNameBase}_${testNameSuffix}`, endpoint.cleanPath, params, endpoint.hasOData);
      }
    });
  
    return pythonTestCode;
  }

  
function generateMethodCodeSmart(endpoints, parent, depth = 0) {
    let methodName = endpoints[0].name;
    let hasODataEndpoint = endpoints.some(endpoint => endpoint.hasOData);
    let hasRegularEndpoint = endpoints.some(endpoint => !endpoint.hasOData);
    let pathParams = new Set();
    let queryParams = new Set();

    // Identify all unique path and query parameters
    endpoints.forEach(endpoint => {
        endpoint.params.forEach(param => {
            if (param.in === 'path') pathParams.add(param.name);
            if (param.in === 'query') queryParams.add(param.name);
        });
    });

    // Adjusting 'odata' in queryParams based on the presence of odata and regular endpoints
    if (hasODataEndpoint && hasRegularEndpoint) queryParams.add('odata'); // Add 'odata' only if both types of endpoints exist

    let indent = ' '.repeat(4 * depth); // 4 spaces per indentation level

    // Construct the initial part of the method signature
    let methodSignatureParts = [`async def ${methodName}(self`];

    // Check if there are any path parameters and append them if present
    if (Array.from(pathParams).length > 0) {
        let pathParamsString = Array.from(pathParams).map(param => `${param}=None`).join(', ');
        methodSignatureParts.push(', ' + pathParamsString);
    }

    // Finish constructing the method signature by adding options
    methodSignatureParts.push(", **options):");

    // Combine the parts to form the full method signature
    let methodSignature = methodSignatureParts.join('');

    // Allowed query parameters
    let allowedParams = `[${Array.from(queryParams).map(q => `'${q}'`).join(', ')}]`;

    // Construct method code lines
    let methodCodeLines = [
        methodSignature,
        `${indent}    allowed_params = ${allowedParams}`,
        `${indent}    query_string = get_query_params(options, allowed_params)`,
        // hasODataEndpoint && hasRegularEndpoint ? "    odata = options.get('odata', 'false').lower() == 'true'" : ""
    ].filter(line => line); // Remove any empty lines

    // Base path and OData path selection based on 'odata' query param
    // let basePath = endpoints.find(ep => !ep.hasOData && ep.params.length === 0)?.path ?? endpoints.find(ep => !ep.hasOData)?.path ?? '';
    // let oDataPath = endpoints.find(ep => ep.hasOData && ep.params.length === 0)?.path ?? endpoints.find(ep => ep.hasOData)?.path ?? '';
    let basePath = endpoints.find(ep => !ep.hasOData)?.path ?? '';
    let oDataPath = endpoints.find(ep => ep.hasOData)?.path ?? '';

    // Directly assign the path based on the presence of odata endpoints
    if (hasODataEndpoint && hasRegularEndpoint) {
        methodCodeLines.push(`${indent}    odata = options.get('odata', 'false').lower() == 'true'`);
        methodCodeLines.push(`${indent}    path = f"${basePath}" if not odata else f"${oDataPath}"`);
    } else {
        // If there's no need to differentiate between odata and regular endpoints, just assign basePath or oDataPath
        methodCodeLines.push(`${indent}    path = f"${basePath || oDataPath}"`);
    }

    // Path parameter substitution needs to consider all cases without prematurely accessing options
    // Simplify the path parameter substitution using the 'odata' variable
    endpoints.forEach(ep => {
        ep.params.filter(p => p.in === 'path').forEach(param => {
            let regularPath = ep.hasOData ? '' : ep.path.replace(`{${param.name}}`, '{' + param.name + '}');
            let oDataPath = ep.hasOData ? ep.path.replace(`{${param.name}}`, '{' + param.name + '}') : '';

            if (hasODataEndpoint && hasRegularEndpoint) {
                // Conditional substitution for standard endpoint
                if (regularPath) {
                    methodCodeLines.push(`${indent}    if not odata and ${param.name} is not None:`);
                    methodCodeLines.push(`${indent}        path = f"${regularPath}"`);
                }
                // Conditional substitution for OData endpoint
                if (oDataPath) {
                    methodCodeLines.push(`${indent}    if odata and ${param.name} is not None:`);
                    methodCodeLines.push(`${indent}        path = f"${oDataPath}"`);
                }
            } else {
                // Direct substitution when only one type of endpoint exists
                let pathToUse = regularPath || oDataPath;
                methodCodeLines.push(`${indent}    if ${param.name} is not None:`);
                methodCodeLines.push(`${indent}        path = f"${pathToUse}"`);
            }
        });
    });

    // Append query string if it exists
    methodCodeLines.push(`${indent}    # Append query string if it exists`);
    methodCodeLines.push(`${indent}    if query_string:`);
    methodCodeLines.push(`${indent}        path = f"{path}?{query_string}"`);
    methodCodeLines.push(`${indent}    return await self.client.getPrivate(path)\n\n`);

    // methodCodeLines.push("    # Append query string if it exists");
    // methodCodeLines.push("    if query_string:");
    // methodCodeLines.push("        path = f\"{path}?{query_string}\"");
    // methodCodeLines.push("    return await self.client.getPrivate(path)\n\n");

    // Ensure proper indentation
    return methodCodeLines.map(line => '    ' + line).join('\n');
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

function generatePythonCode(fileName, fileNameIntegrationTest, entityName, entityMethods, parent = "") {

    console.log("\ngeneratePythonCode, parent:", parent, " ,entityName:", entityName);

    if (parent === "") parent = entityName;

    let className = generateClassName(parent, entityName);

    // let code = `class ${capitalizeFirstLetter(entityName)}:\n`;
    let code = `class ${capitalizeFirstLetter(className)}:\n`;
    let codeIntegrationTest = "";

    code += `    def __init__(self, client):\n`;
    code += `        self.client = client\n\n`;

    console.log("entityMethods 1:", entityMethods);

    // Dynamically add child entities to the Core class
    Object.keys(entityMethods).forEach(entity => {
        if (entity != "endpoints") {
            let subClassName = generateClassName(parent, entity);
            // code += `        self.${entity.toLowerCase()} = ${capitalizeFirstLetter(entity)}(self.client)\n`;
            code += `        self.${entity.toLowerCase()} = ${className}${capitalizeFirstLetter(entity)}(self.client)\n`;
        }
    });

    code += "\n";

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
    
        Object.entries(endpointsByCleanPath).forEach(([cleanPath, endpoints]) => {
            // Use cleanPath to generate method name, or any other logic to determine the method name
            code += generateMethodCodeSmart(endpoints, parent);
            codeIntegrationTest += generateIntegrationTestCode(endpoints, parent);
        });
    
        code += '\n'; 
    }

    writeCodeToFile(fileName, code);

    writeCodeToFile(fileNameIntegrationTest, codeIntegrationTest);

    console.log("GENERATE ENTITIES CODE");

    // Recursively create child entities classes
    Object.keys(entityMethods).forEach(entity => {
        if (entity != "endpoints") {
            let parent_ = parent === "" ? entityName : `${parent}_${entityName}`;
            generatePythonCode(fileName, fileNameIntegrationTest, entity, entityMethods[entity], parent_);
        }
    });
}
