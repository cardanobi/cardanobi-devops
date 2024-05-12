from contextlib import asynccontextmanager
import asyncio
import pytest
import time
from cardanobi import CardanoBI
import os
from dotenv import load_dotenv
import json

# Load environment variables from .env file
load_dotenv()

apiKey = os.getenv('CBI_API_KEY')
apiSecret = os.getenv('CBI_API_SECRET')
network = os.getenv('CBI_ENV')
logFile = os.getenv('LOG_FILE_PATH')
unitTestOutputDir = os.getenv('UNIT_TEST_OUTPUT_DIRECTORY', 'test_output')

# Create the output directory if it doesn't exist
os.makedirs(unitTestOutputDir, exist_ok=True)

# Asynchronous context manager for test execution
@asynccontextmanager
async def my_context(test_name):
    start_time = time.time()
    try:
        yield
        end_time = time.time()
        logger(f"{test_name} PASSED in {(end_time - start_time) * 1000:.2f}ms\n")
    except Exception as e:
        end_time = time.time()
        logger(f"{test_name} FAILED in {(end_time - start_time) * 1000:.2f}ms. Error: {e}\n")

def logger(message):
    RED = '\033[91m'
    GREEN = '\033[92m'
    RESET = '\033[0m'
    
    if "FAILED" in message:
        colored_message = message.replace("FAILED", f"{RED}FAILED{RESET}")
    elif "PASSED" in message:
        colored_message = message.replace("PASSED", f"{GREEN}PASSED{RESET}")
    else:
        colored_message = message

    print(colored_message)  # Print to stdout
    with open(logFile, "a") as log_file:  # Write to file
        log_file.write(message + "\n")  # Write original message without color codes

def save_response_to_file(response, test_name):
    """ Save response JSON to a file in the specified directory """
    output_path = os.path.join(unitTestOutputDir, f"{test_name}.json")
    with open(output_path, 'w') as f:
        json.dump(response, f, indent=4)  # Save JSON with pretty printing
        
# Test functions using the above context manager and fixture
@pytest.mark.asyncio
async def test_api_bi_addresses_stats_with_specific_params():
    async with my_context("test_api_bi_addresses_stats_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.bi.addresses.stats_(address="stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_bi_addresses_stats_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_bi_pools_stats_with_specific_params():
    async with my_context("test_api_bi_pools_stats_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.bi.pools.stats_(pool_hash="pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_bi_pools_stats_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_bi_pools_stats_epochs_with_specific_params():
    async with my_context("test_api_bi_pools_stats_epochs_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.bi.pools.stats.epochs_(epoch_no=394)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_bi_pools_stats_epochs_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_bi_pools_stats_lifetime_with_specific_params():
    async with my_context("test_api_bi_pools_stats_lifetime_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.bi.pools.stats.lifetime_(pool_hash="pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_bi_pools_stats_lifetime_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  