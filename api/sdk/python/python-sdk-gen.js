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

    // Example: Print out the collected Core endpoints
    // console.log('Core Endpoints:', coreEndpoints);
    // console.log('BI Endpoints:', biEndpoints);

    // Further processing to generate core.py and bi.py would go here
    generatePythonCode('Core', coreEndpoints);
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


// Helper function to generate method code
function generateMethodCode(endpointInfo) {
    // console.log("generateMethodCode: ", endpointInfo);

    let methodCodeLines = [
        `async def ${endpointInfo.name}(self`,
    ];
    let pathParams = [];
    let queryParams = [];

    if (endpointInfo && endpointInfo.params) {
        pathParams = endpointInfo.params.filter(p => p.in === 'path');
        queryParams = endpointInfo.params.filter(p => p.in === 'query').map(p => p.name);

        // Adding path parameters before **options
        pathParams.forEach(param => {
            methodCodeLines[0] += `, ${param.name}`;
        });
        methodCodeLines[0] += ', **options):';
    } else {
        methodCodeLines[0] += ', **options):';
    }

    let allowedParams = `[${queryParams.map(q => `'${q}'`).join(', ')}]`;
    methodCodeLines.push(`    allowed_params = ${allowedParams}`);
    methodCodeLines.push(`    query_string = get_query_params(options, allowed_params)`);
    methodCodeLines.push(`    path = f"${endpointInfo.path}"`);
    methodCodeLines.push("    # Append query string if it exists");
    methodCodeLines.push("    if query_string:");
    methodCodeLines.push("        path = f\"{path}?{query_string}\"");
    methodCodeLines.push("    return await self.client.getPrivate(path)\n");

    // Adding a tab to each line to ensure proper indentation
    return methodCodeLines.map(line => '\t' + line).join('\n');
}

function generateMethodCodeSmart(endpoints) {
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
        `    allowed_params = ${allowedParams}`,
        `    query_string = get_query_params(options, allowed_params)`,
        // hasODataEndpoint && hasRegularEndpoint ? "    odata = options.get('odata', 'false').lower() == 'true'" : ""
    ].filter(line => line); // Remove any empty lines

    // Base path and OData path selection based on 'odata' query param
    // let basePath = endpoints.find(ep => !ep.hasOData && ep.params.length === 0)?.path ?? endpoints.find(ep => !ep.hasOData)?.path ?? '';
    // let oDataPath = endpoints.find(ep => ep.hasOData && ep.params.length === 0)?.path ?? endpoints.find(ep => ep.hasOData)?.path ?? '';
    let basePath = endpoints.find(ep => !ep.hasOData)?.path ?? '';
    let oDataPath = endpoints.find(ep => ep.hasOData)?.path ?? '';

    // Directly assign the path based on the presence of odata endpoints
    if (hasODataEndpoint && hasRegularEndpoint) {
        methodCodeLines.push("    odata = options.get('odata', 'false').lower() == 'true'");
        methodCodeLines.push(`    path = f"${basePath}" if not odata else f"${oDataPath}"`);
    } else {
        // If there's no need to differentiate between odata and regular endpoints, just assign basePath or oDataPath
        methodCodeLines.push(`    path = f"${basePath || oDataPath}"`);
    }

    // Path parameter substitution needs to consider all cases without prematurely accessing options
    // Simplify the path parameter substitution using the 'odata' variable
    endpoints.forEach(ep => {
        ep.params.filter(p => p.in === 'path').forEach(param => {
            let regularPath = ep.hasOData ? '' : ep.path.replace(`{${param.name}}`, '${' + param.name + '}');
            let oDataPath = ep.hasOData ? ep.path.replace(`{${param.name}}`, '${' + param.name + '}') : '';

            if (hasODataEndpoint && hasRegularEndpoint) {
                // Conditional substitution for standard endpoint
                if (regularPath) {
                    methodCodeLines.push(`    if not odata and ${param.name} is not None:`);
                    methodCodeLines.push(`        path = f"${regularPath}"`);
                }
                // Conditional substitution for OData endpoint
                if (oDataPath) {
                    methodCodeLines.push(`    if odata and ${param.name} is not None:`);
                    methodCodeLines.push(`        path = f"${oDataPath}"`);
                }
            } else {
                // Direct substitution when only one type of endpoint exists
                let pathToUse = regularPath || oDataPath;
                methodCodeLines.push(`    if ${param.name} is not None:`);
                methodCodeLines.push(`        path = f"${pathToUse}"`);
            }
        });
    });

    // Append query string if it exists
    methodCodeLines.push("    # Append query string if it exists");
    methodCodeLines.push("    if query_string:");
    methodCodeLines.push("        path = f\"{path}?{query_string}\"");
    methodCodeLines.push("    return await self.client.getPrivate(path)\n\n");

    // Ensure proper indentation
    return methodCodeLines.map(line => '    ' + line).join('\n');
}


function generatePythonCode(domain, endpoints) {
    const entities = new Set();

    endpoints.forEach((endpoint) => {
        endpoint.tags.forEach((tag) => {
            if (tag !== domain) {
                entities.add(tag);
            }
        });
    });

    // console.log(entities);

    let entityMethods = { core: {}, bi: {} };

    console.log("entityMethods.core 0:", entityMethods.core);

    endpoints.forEach((endpoint) => {
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
    console.log("entityMethods.core 0b:", entityMethods.core);

    let code = `from utils import get_query_params\n\n`;

    code += `class ${domain}:\n`;
    code += `    def __init__(self, client):\n`;
    code += `        self.client = client\n\n`;

    console.log("entityMethods.core 1:", entityMethods.core);

    // Dynamically add child entities to the Core class
    Object.keys(entityMethods.core).forEach(entity => {
        if (entity != "endpoints") {
            code += `        self.${entity.toLowerCase()} = ${capitalizeFirstLetter(entity)}(self.client)\n`;
        }
    });

    code += "\n";

    // Generate classes and endpoint methods for Core class
    // Assuming entityMethods.core.endpoints is an array of endpoint objects
    console.log("entityMethods.core:", entityMethods.core);
    console.log("entityMethods.core.endpoints:", entityMethods.core.endpoints);
    const endpointsByCleanPath = entityMethods.core.endpoints.reduce((acc, endpoint) => {
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

    console.log("GENERATE ENTITIES CODE");

    // Generate classes and endpoint methods for child entities
    Object.entries(entityMethods.core).forEach(([entityName, children]) => {

        if (entityName != "endpoints") {
            console.log("entityName:", entityName, " ,children:", children);

            code += `class ${capitalizeFirstLetter(entityName)}:\n`;
            code += `    def __init__(self, client):\n`;
            code += `        self.client = client\n\n`;

            // Dynamically add child entities to the Core class
            Object.keys(children).forEach(entity => {
                if (entity != "endpoints") {
                    code += `        self.${entity.toLowerCase()} = ${capitalizeFirstLetter(entity)}(self.client)\n`;
                }
            });

            code += "\n";

            if (children.endpoints) {
                const endpointsByCleanPath = children.endpoints.reduce((acc, endpoint) => {
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
            }
        }
    });

    const fileName = path.join(__dirname, `${domain.toLowerCase()}.py`);
    fs.writeFile(fileName, code, (err) => {
        if (err) {
            console.error(`Error writing the ${domain}.py file:`, err);
        } else {
            console.log(`${domain}.py file has been generated successfully.`);
        }
    });
}
