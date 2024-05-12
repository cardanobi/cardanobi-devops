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

    console.log(entityMethods);

    // Example: Print out the collected Core endpoints
    // console.log('Core Endpoints:', coreEndpoints);
    // console.log('BI Endpoints:', biEndpoints);

    // Further processing to generate core.py and bi.py would go here
    // Handle Core Domain
    const fileName = path.join(__dirname, `core.py`);
    let code = `from utils import get_query_params\n\n`;
    writeCodeToFile(fileName, code);
    generatePythonCode(fileName, 'core', entityMethods.core);
    
    // generatePythonCode('BI', biEndpoints);
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

function generateMethodCodeSmart(endpoints, depth = 0) {
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


function generatePythonCode(fileName, entityName, entityMethods, parent="") {
    let code = `class ${capitalizeFirstLetter(entityName)}:\n`;

    code += `    def __init__(self, client):\n`;
    code += `        self.client = client\n\n`;

    console.log("entityMethods 1:", entityMethods);

    // Dynamically add child entities to the Core class
    Object.keys(entityMethods).forEach(entity => {
        if (entity != "endpoints") {
            code += `        self.${entity.toLowerCase()} = ${capitalizeFirstLetter(entity)}(self.client)\n`;
        }
    });

    code += "\n";

    // Generate endpoint methods for given entityName class
    // Assuming entityMethods.endpoints is an array of endpoint objects
    if (entityMethods.endpoints) {
        console.log("entityMethods.endpoints:", entityMethods.endpoints);
        console.log("parent:", parent);
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
            code += generateMethodCodeSmart(endpoints);
        });
    
        code += '\n'; 
    }

    writeCodeToFile(fileName, code);

    console.log("GENERATE ENTITIES CODE");

    // Recursively create child entities classes
    Object.keys(entityMethods).forEach(entity => {
        if (entity != "endpoints") {
            let parent_ = parent === "" ? entityName : `${parent}_${entityName}`;
            generatePythonCode(fileName, entity, entityMethods[entity], parent_);
        }
    });
}
