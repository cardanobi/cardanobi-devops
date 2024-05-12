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

    if (hasODataEndpoint && hasRegularEndpoint) queryParams.add('odata'); // Add 'odata' only if both types of endpoints exist

    let indent = ' '.repeat(4 * depth); // 4 spaces per indentation level

    // Construct the initial part of the method signature
    let methodSignatureParts = [`${indent}async def ${methodName}(self`];

    // Check if there are any path parameters and append them if present
    if (Array.from(pathParams).length > 0) {
        let pathParamsString = Array.from(pathParams).map(param => `${param}=None`).join(', ');
        methodSignatureParts.push(', ' + pathParamsString);
    }

    // Finish constructing the method signature by adding options
    methodSignatureParts.push(", **options):");

    // Combine the parts to form the full method signature
    let methodSignature = methodSignatureParts.join('');

    let allowedParams = `[${Array.from(queryParams).map(q => `'${q}'`).join(', ')}]`;

    // Construct method code lines
    let methodCodeLines = [
        methodSignature,
        `${indent}    allowed_params = ${allowedParams}`,
        `${indent}    query_string = get_query_params(options, allowed_params)`,
    ];

    let basePath = endpoints.find(ep => !ep.hasOData)?.path ?? '';
    let oDataPath = endpoints.find(ep => ep.hasOData)?.path ?? '';

    // Path assignment logic adjusted for 'odata' option
    if (hasODataEndpoint && hasRegularEndpoint) {
        methodCodeLines.push(`${indent}    odata = options.get('odata', 'false').lower() == 'true'`);
        methodCodeLines.push(`${indent}    path = f"${basePath}" if not odata else f"${oDataPath}"`);
    } else {
        methodCodeLines.push(`${indent}    path = f"${basePath || oDataPath}"`);
    }

    // Path parameter substitution logic
    endpoints.forEach(ep => {
        ep.params.filter(p => p.in === 'path').forEach(param => {
            let pathWithParam = ep.path.replace(`{${param.name}}`, '${' + param.name + '}');
            methodCodeLines.push(`${indent}    if ${param.name} is not None:`);
            methodCodeLines.push(`${indent}        path = f"${pathWithParam}"`);
        });
    });

    // Append query string if it exists, using the adjusted indentation
    methodCodeLines.push(`${indent}    # Append query string if it exists`);
    methodCodeLines.push(`${indent}    if query_string:`);
    methodCodeLines.push(`${indent}        path = f"{path}?{query_string}"`);
    methodCodeLines.push(`${indent}    return await self.client.getPrivate(path)\n`);

    // Join all lines with newlines to form the complete method definition
    return methodCodeLines.join('\n');
}
