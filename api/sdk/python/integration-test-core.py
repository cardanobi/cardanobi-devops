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
async def test_api_core_accounts_with_specific_params():
    async with my_context("test_api_core_accounts_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.accounts_(stake_address="stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_accounts_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_addressesinfo_with_specific_params():
    async with my_context("test_api_core_addressesinfo_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.addressesinfo_(address="stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma", odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_addressesinfo_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_assets_with_specific_params():
    async with my_context("test_api_core_assets_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.assets_(fingerprint="asset1w8wujx5xpxk88u94t0c60lsjlgwpd635a3c3lc")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_assets_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_with_specific_params():
    async with my_context("test_api_core_blocks_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks_(block_no=8415364)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_with_specific_params():
    async with my_context("test_api_core_blocks_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks_(block_hash="89ff1090614105a919c9ccc8bb3914aaef1ddd28214a4d55ff65436d2c9fc0b2")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_with_odata():
    async with my_context("test_api_core_blocks_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_without_parameters():
    async with my_context("test_api_core_epochs_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_with_specific_params():
    async with my_context("test_api_core_epochs_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs_(epoch_no=394)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_with_odata():
    async with my_context("test_api_core_epochs_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_with_specific_params():
    async with my_context("test_api_core_epochs_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs_(epoch_no=394, odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochsparams_with_odata():
    async with my_context("test_api_core_epochsparams_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochsparams_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochsparams_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochsparams_with_specific_params():
    async with my_context("test_api_core_epochsparams_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochsparams_(epoch_no=394, odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochsparams_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochsstakes_with_odata():
    async with my_context("test_api_core_epochsstakes_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochsstakes_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochsstakes_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_polls_with_specific_params():
    async with my_context("test_api_core_polls_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.polls_(poll_hash="96861fe7da8d45ba5db95071ed3889ed1412929f33610636c072a4b5ab550211")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_polls_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolshashes_with_odata():
    async with my_context("test_api_core_poolshashes_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolshashes_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolshashes_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsmetadata_with_odata():
    async with my_context("test_api_core_poolsmetadata_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsmetadata_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsmetadata_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsmetadata_with_specific_params():
    async with my_context("test_api_core_poolsmetadata_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsmetadata_(pool_id=4268, odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsmetadata_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsofflinedata_with_odata():
    async with my_context("test_api_core_poolsofflinedata_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsofflinedata_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsofflinedata_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsofflinedata_with_specific_params():
    async with my_context("test_api_core_poolsofflinedata_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsofflinedata_(pool_id=4268, odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsofflinedata_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsofflinefetcherrors_with_odata():
    async with my_context("test_api_core_poolsofflinefetcherrors_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsofflinefetcherrors_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsofflinefetcherrors_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsofflinefetcherrors_with_specific_params():
    async with my_context("test_api_core_poolsofflinefetcherrors_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsofflinefetcherrors_(pool_id=4268, odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsofflinefetcherrors_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsrelays_with_odata():
    async with my_context("test_api_core_poolsrelays_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsrelays_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsrelays_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsrelays_with_specific_params():
    async with my_context("test_api_core_poolsrelays_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsrelays_(update_id=1, odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsrelays_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsupdates_with_odata():
    async with my_context("test_api_core_poolsupdates_with_odata"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsupdates_(odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsupdates_with_odata")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_poolsupdates_with_specific_params():
    async with my_context("test_api_core_poolsupdates_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.poolsupdates_(pool_id=4268, odata='true')
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_poolsupdates_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_with_specific_params():
    async with my_context("test_api_core_transactions_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions_(transaction_hash="5f6f72b00ae982492823fb541153e6c2afc9cb7231687f2a5d82a994f61764a0")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_accounts_rewards_with_specific_params():
    async with my_context("test_api_core_accounts_rewards_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.accounts.rewards_(stake_address="stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_accounts_rewards_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_accounts_staking_with_specific_params():
    async with my_context("test_api_core_accounts_staking_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.accounts.staking_(stake_address="stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_accounts_staking_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_accounts_delegations_with_specific_params():
    async with my_context("test_api_core_accounts_delegations_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.accounts.delegations_(stake_address="stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_accounts_delegations_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_accounts_registrations_with_specific_params():
    async with my_context("test_api_core_accounts_registrations_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.accounts.registrations_(stake_address="stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_accounts_registrations_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_accounts_withdrawals_with_specific_params():
    async with my_context("test_api_core_accounts_withdrawals_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.accounts.withdrawals_(stake_address="stake1u9frlh9lvpdjva46ge0yc4c8zg5e0d37ch42zyyrzmu2hygnmy4xc")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_accounts_withdrawals_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_accounts_mirs_with_specific_params():
    async with my_context("test_api_core_accounts_mirs_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.accounts.mirs_(stake_address="stake1uypy44wqjznc5w9ns9gsguz4ta83jekrg9d0wupa7j3zsacwvq5ex")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_accounts_mirs_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_accounts_addresses_with_specific_params():
    async with my_context("test_api_core_accounts_addresses_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.accounts.addresses_(stake_address="stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_accounts_addresses_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_accounts_assets_with_specific_params():
    async with my_context("test_api_core_accounts_assets_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.accounts.assets_(stake_address="stake1uyq4f9rye96ywptukdypkdu69gc4sd34hwzd940pxslczhc7n5vyt")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_accounts_assets_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_addresses_info_with_specific_params():
    async with my_context("test_api_core_addresses_info_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.addresses.info_(address="stake1u8a9qstrmj4rvc3k5z8fems7f0j2vztz8det2klgakhfc8ce79fma")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_addresses_info_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_assets_history_with_specific_params():
    async with my_context("test_api_core_assets_history_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.assets.history_(fingerprint="asset1gqp4wdmclgw2tqmkm3nq7jdstvqpesdj3agnel")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_assets_history_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_assets_transactions_with_specific_params():
    async with my_context("test_api_core_assets_transactions_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.assets.transactions_(fingerprint="asset1gqp4wdmclgw2tqmkm3nq7jdstvqpesdj3agnel")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_assets_transactions_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_assets_addresses_with_specific_params():
    async with my_context("test_api_core_assets_addresses_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.assets.addresses_(fingerprint="asset1gqp4wdmclgw2tqmkm3nq7jdstvqpesdj3agnel")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_assets_addresses_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_assets_policies_with_specific_params():
    async with my_context("test_api_core_assets_policies_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.assets.policies_(policy_hash="706e1c53ed984b016f2c0fc79a450fdb572aa21e4e87d6f74d0b6e8a")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_assets_policies_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_latest_without_parameters():
    async with my_context("test_api_core_blocks_latest_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks.latest_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_latest_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_transactions_with_specific_params():
    async with my_context("test_api_core_blocks_transactions_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks.transactions_(block_no=8415364)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_transactions_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_transactions_with_specific_params():
    async with my_context("test_api_core_blocks_transactions_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks.transactions_(block_hash="89ff1090614105a919c9ccc8bb3914aaef1ddd28214a4d55ff65436d2c9fc0b2")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_transactions_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_epochs_slots_with_specific_params():
    async with my_context("test_api_core_blocks_epochs_slots_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks.epochs.slots_(epoch_no=394, slot_no=85165743)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_epochs_slots_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_history_prev_with_specific_params():
    async with my_context("test_api_core_blocks_history_prev_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks.history.prev_(block_no=8415364)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_history_prev_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_history_next_with_specific_params():
    async with my_context("test_api_core_blocks_history_next_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks.history.next_(block_no=8415364)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_history_next_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_latest_pools_with_specific_params():
    async with my_context("test_api_core_blocks_latest_pools_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks.latest.pools_(pool_hash="pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_latest_pools_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_latest_transactions_without_parameters():
    async with my_context("test_api_core_blocks_latest_transactions_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks.latest.transactions_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_latest_transactions_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_blocks_pools_history_with_specific_params():
    async with my_context("test_api_core_blocks_pools_history_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.blocks.pools.history_(pool_hash="pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_blocks_pools_history_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_latest_without_parameters():
    async with my_context("test_api_core_epochs_latest_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs.latest_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_latest_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_params_without_parameters():
    async with my_context("test_api_core_epochs_params_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs.params_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_params_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_params_with_specific_params():
    async with my_context("test_api_core_epochs_params_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs.params_(epoch_no=394)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_params_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_params_latest_without_parameters():
    async with my_context("test_api_core_epochs_params_latest_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs.params.latest_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_params_latest_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_stakes_pools_with_specific_params():
    async with my_context("test_api_core_epochs_stakes_pools_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs.stakes.pools_(pool_hash="pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_stakes_pools_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_stakes_pools_with_specific_params():
    async with my_context("test_api_core_epochs_stakes_pools_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs.stakes.pools_(epoch_no=394, pool_hash="pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_stakes_pools_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_epochs_latest_stakes_pools_with_specific_params():
    async with my_context("test_api_core_epochs_latest_stakes_pools_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.epochs.latest.stakes.pools_(pool_hash="pool1y24nj4qdkg35nvvnfawukauggsxrxuy74876cplmxsee29w5axc")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_epochs_latest_stakes_pools_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_hashes_without_parameters():
    async with my_context("test_api_core_pools_hashes_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.hashes_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_hashes_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_metadata_without_parameters():
    async with my_context("test_api_core_pools_metadata_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.metadata_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_metadata_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_metadata_with_specific_params():
    async with my_context("test_api_core_pools_metadata_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.metadata_(pool_id=4268)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_metadata_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_offlinedata_without_parameters():
    async with my_context("test_api_core_pools_offlinedata_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.offlinedata_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_offlinedata_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_offlinedata_with_specific_params():
    async with my_context("test_api_core_pools_offlinedata_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.offlinedata_(pool_id=4268)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_offlinedata_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_offlinedata_with_specific_params():
    async with my_context("test_api_core_pools_offlinedata_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.offlinedata_(ticker="ADACT")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_offlinedata_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_offlinefetcherrors_without_parameters():
    async with my_context("test_api_core_pools_offlinefetcherrors_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.offlinefetcherrors_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_offlinefetcherrors_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_offlinefetcherrors_with_specific_params():
    async with my_context("test_api_core_pools_offlinefetcherrors_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.offlinefetcherrors_(pool_id=4268)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_offlinefetcherrors_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_updates_without_parameters():
    async with my_context("test_api_core_pools_updates_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.updates_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_updates_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_updates_with_specific_params():
    async with my_context("test_api_core_pools_updates_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.updates_(pool_id=4268)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_updates_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_updates_with_specific_params():
    async with my_context("test_api_core_pools_updates_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.updates_(vrf_key_hash="9be345bcbcb0cf0559b1135467fd2e4c78c741898cdf8bcb737b2dc5122632df")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_updates_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_metadata_hashes_with_specific_params():
    async with my_context("test_api_core_pools_metadata_hashes_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.metadata.hashes_(meta_hash="42771b05b30f180890980613b3147f6bb797fe1f8a83e92d39a3135ec9559ea8")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_metadata_hashes_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_metadata_offlinedata_with_specific_params():
    async with my_context("test_api_core_pools_metadata_offlinedata_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.metadata.offlinedata_(meta_hash="42771b05b30f180890980613b3147f6bb797fe1f8a83e92d39a3135ec9559ea8")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_metadata_offlinedata_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_relays_updates_without_parameters():
    async with my_context("test_api_core_pools_relays_updates_without_parameters"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.relays.updates_()
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_relays_updates_without_parameters")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_relays_updates_with_specific_params():
    async with my_context("test_api_core_pools_relays_updates_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.relays.updates_(update_id=1)
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_relays_updates_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_pools_relays_updates_with_specific_params():
    async with my_context("test_api_core_pools_relays_updates_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.pools.relays.updates_(vrf_key_hash="9be345bcbcb0cf0559b1135467fd2e4c78c741898cdf8bcb737b2dc5122632df")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_pools_relays_updates_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_utxos_with_specific_params():
    async with my_context("test_api_core_transactions_utxos_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.utxos_(transaction_hash="5f6f72b00ae982492823fb541153e6c2afc9cb7231687f2a5d82a994f61764a0")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_utxos_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_stake_address_registrations_with_specific_params():
    async with my_context("test_api_core_transactions_stake_address_registrations_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.stake_address_registrations_(transaction_hash="13919fc14338f13fa10497293f709f9c12c6275c5b38baa0c60786ffdd51bebb")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_stake_address_registrations_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_stake_address_delegations_with_specific_params():
    async with my_context("test_api_core_transactions_stake_address_delegations_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.stake_address_delegations_(transaction_hash="e963b50c5a1078f0fbe11c375d047af3a1b2112538ed6cf852809ebbf4dd8440")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_stake_address_delegations_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_withdrawals_with_specific_params():
    async with my_context("test_api_core_transactions_withdrawals_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.withdrawals_(transaction_hash="cb44c5dd07ab3fee81f05ddd3e4596d2664e6c0ae77bccf99d1c9605dd01808d")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_withdrawals_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_treasury_with_specific_params():
    async with my_context("test_api_core_transactions_treasury_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.treasury_(transaction_hash="0bc50b20e16268419048790f6ae3667a1480418dd9faed543bc0e8ca32ea7a08")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_treasury_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_reserves_with_specific_params():
    async with my_context("test_api_core_transactions_reserves_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.reserves_(transaction_hash="27dff3f43c460e779e35eff505f5f159c4283a8221b31ee17cdcd5b31ad221ba")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_reserves_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_param_proposals_with_specific_params():
    async with my_context("test_api_core_transactions_param_proposals_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.param_proposals_(transaction_hash="62c3c13187423c47f629e6187f36fbd61a9ba1d05d101588340cfbfdf47b22d2")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_param_proposals_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_retiring_pools_with_specific_params():
    async with my_context("test_api_core_transactions_retiring_pools_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.retiring_pools_(transaction_hash="0d8eadd3bd58bd1a34641ea4100de509f081fe5dd7ecd33d7da52cbeb8e93494")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_retiring_pools_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_updating_pools_with_specific_params():
    async with my_context("test_api_core_transactions_updating_pools_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.updating_pools_(transaction_hash="37b67370c0e71b6e15d6d5f564a5069461e472a26e6f46a813743458285aef8d")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_updating_pools_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_metadata_with_specific_params():
    async with my_context("test_api_core_transactions_metadata_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.metadata_(transaction_hash="6b85afe3fc01c6d3503a5dac8343b56b67f504bb2399deba8b09f8024790b9c4")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_metadata_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_assetmints_with_specific_params():
    async with my_context("test_api_core_transactions_assetmints_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.assetmints_(transaction_hash="5f6f72b00ae982492823fb541153e6c2afc9cb7231687f2a5d82a994f61764a0")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_assetmints_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  
@pytest.mark.asyncio
async def test_api_core_transactions_redeemers_with_specific_params():
    async with my_context("test_api_core_transactions_redeemers_with_specific_params"):
        CBI = CardanoBI(apiKey=apiKey, apiSecret=apiSecret, network=network)
        response = await CBI.core.transactions.redeemers_(transaction_hash="e584995ed133ae25e5c918d794efa415e10352b0d0e08aa02a196bbd605b9e69")
        await CBI.client.session.close()
        save_response_to_file(response, "test_api_core_transactions_redeemers_with_specific_params")
        if 'status' in response and response.get('status') != 200:
            error_message = response.get('error', 'Unknown error')
            pytest.fail(f"Expected HTTP 200, got {response['status']} with error: {error_message}")
  