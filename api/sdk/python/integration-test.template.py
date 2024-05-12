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