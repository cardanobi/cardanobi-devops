from utils import get_query_params

class Core:
    def __init__(self, client):
        self.client = client

        self.accounts = CoreAccounts(self.client)
        self.addresses = CoreAddresses(self.client)
        self.assets = CoreAssets(self.client)
        self.blocks = CoreBlocks(self.client)
        self.epochs = CoreEpochs(self.client)
        self.pools = CorePools(self.client)
        self.transactions = CoreTransactions(self.client)

    async def accounts_(self, stake_address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/accounts/{stake_address}"
        if stake_address is not None:
            path = f"/api/core/accounts/{stake_address}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def addressesinfo_(self, address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/odata/addressesinfo/{address}"
        if address is not None:
            path = f"/api/core/odata/addressesinfo/{address}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def assets_(self, fingerprint=None, **options):
        allowed_params = ['page_no', 'page_size', 'order']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/assets"
        if fingerprint is not None:
            path = f"/api/core/assets/{fingerprint}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def blocks_(self, block_no=None, block_hash=None, **options):
        allowed_params = ['block_no', 'depth', 'odata']
        query_string = get_query_params(options, allowed_params)
        odata = options.get('odata', 'false').lower() == 'true'
        path = f"/api/core/blocks/{block_no}" if not odata else f"/api/core/odata/blocks"
        if not odata and block_no is not None:
            path = f"/api/core/blocks/{block_no}"
        if not odata and block_hash is not None:
            path = f"/api/core/blocks/{block_hash}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def epochs_(self, epoch_no=None, **options):
        allowed_params = ['odata']
        query_string = get_query_params(options, allowed_params)
        odata = options.get('odata', 'false').lower() == 'true'
        path = f"/api/core/epochs" if not odata else f"/api/core/odata/epochs"
        if not odata and epoch_no is not None:
            path = f"/api/core/epochs/{epoch_no}"
        if odata and epoch_no is not None:
            path = f"/api/core/odata/epochs/{epoch_no}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def epochsparams_(self, epoch_no=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/odata/epochsparams"
        if epoch_no is not None:
            path = f"/api/core/odata/epochsparams/{epoch_no}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def epochsstakes_(self, **options):
        allowed_params = ['epoch_no', 'pool_hash', 'page_no', 'page_size', 'order']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/odata/epochsstakes"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def polls_(self, poll_hash=None, **options):
        allowed_params = ['page_no', 'page_size', 'order']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/polls"
        if poll_hash is not None:
            path = f"/api/core/polls/{poll_hash}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def poolshashes_(self, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/odata/poolshashes"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def poolsmetadata_(self, pool_id=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/odata/poolsmetadata"
        if pool_id is not None:
            path = f"/api/core/odata/poolsmetadata/{pool_id}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def poolsofflinedata_(self, pool_id=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/odata/poolsofflinedata"
        if pool_id is not None:
            path = f"/api/core/odata/poolsofflinedata/{pool_id}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def poolsofflinefetcherrors_(self, pool_id=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/odata/poolsofflinefetcherrors"
        if pool_id is not None:
            path = f"/api/core/odata/poolsofflinefetcherrors/{pool_id}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def poolsrelays_(self, update_id=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/odata/poolsrelays"
        if update_id is not None:
            path = f"/api/core/odata/poolsrelays/{update_id}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def poolsupdates_(self, pool_id=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/odata/poolsupdates"
        if pool_id is not None:
            path = f"/api/core/odata/poolsupdates/{pool_id}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def transactions_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreAccounts:
    def __init__(self, client):
        self.client = client


    async def rewards_(self, stake_address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/accounts/{stake_address}/rewards"
        if stake_address is not None:
            path = f"/api/core/accounts/{stake_address}/rewards"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def staking_(self, stake_address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/accounts/{stake_address}/staking"
        if stake_address is not None:
            path = f"/api/core/accounts/{stake_address}/staking"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def delegations_(self, stake_address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/accounts/{stake_address}/delegations"
        if stake_address is not None:
            path = f"/api/core/accounts/{stake_address}/delegations"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def registrations_(self, stake_address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/accounts/{stake_address}/registrations"
        if stake_address is not None:
            path = f"/api/core/accounts/{stake_address}/registrations"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def withdrawals_(self, stake_address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/accounts/{stake_address}/withdrawals"
        if stake_address is not None:
            path = f"/api/core/accounts/{stake_address}/withdrawals"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def mirs_(self, stake_address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/accounts/{stake_address}/mirs"
        if stake_address is not None:
            path = f"/api/core/accounts/{stake_address}/mirs"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def addresses_(self, stake_address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/accounts/{stake_address}/addresses"
        if stake_address is not None:
            path = f"/api/core/accounts/{stake_address}/addresses"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def assets_(self, stake_address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/accounts/{stake_address}/assets"
        if stake_address is not None:
            path = f"/api/core/accounts/{stake_address}/assets"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreAddresses:
    def __init__(self, client):
        self.client = client


    async def info_(self, address=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/addresses/{address}/info"
        if address is not None:
            path = f"/api/core/addresses/{address}/info"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreAssets:
    def __init__(self, client):
        self.client = client


    async def history_(self, fingerprint=None, **options):
        allowed_params = ['page_no', 'page_size', 'order']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/assets/{fingerprint}/history"
        if fingerprint is not None:
            path = f"/api/core/assets/{fingerprint}/history"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def transactions_(self, fingerprint=None, **options):
        allowed_params = ['page_no', 'page_size', 'order']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/assets/{fingerprint}/transactions"
        if fingerprint is not None:
            path = f"/api/core/assets/{fingerprint}/transactions"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def addresses_(self, fingerprint=None, **options):
        allowed_params = ['page_no', 'page_size', 'order']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/assets/{fingerprint}/addresses"
        if fingerprint is not None:
            path = f"/api/core/assets/{fingerprint}/addresses"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def policies_(self, policy_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/assets/policies/{policy_hash}"
        if policy_hash is not None:
            path = f"/api/core/assets/policies/{policy_hash}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreBlocks:
    def __init__(self, client):
        self.client = client

        self.epochs = CoreBlocksEpochs(self.client)
        self.history = CoreBlocksHistory(self.client)
        self.latest = CoreBlocksLatest(self.client)
        self.pools = CoreBlocksPools(self.client)

    async def latest_(self, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/blocks/latest"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def history_(self, **options):
        allowed_params = ['block_no', 'depth']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/blocks/history"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def transactions_(self, block_no=None, block_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/blocks/{block_no}/transactions"
        if block_no is not None:
            path = f"/api/core/blocks/{block_no}/transactions"
        if block_hash is not None:
            path = f"/api/core/blocks/{block_hash}/transactions"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreBlocksEpochs:
    def __init__(self, client):
        self.client = client


    async def slots_(self, epoch_no=None, slot_no=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/blocks/epochs/{epoch_no}/slots/{slot_no}"
        if epoch_no is not None:
            path = f"/api/core/blocks/epochs/{epoch_no}/slots/{slot_no}"
        if slot_no is not None:
            path = f"/api/core/blocks/epochs/{epoch_no}/slots/{slot_no}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreBlocksHistory:
    def __init__(self, client):
        self.client = client


    async def prev_(self, block_no=None, **options):
        allowed_params = ['depth']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/blocks/history/prev/{block_no}"
        if block_no is not None:
            path = f"/api/core/blocks/history/prev/{block_no}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def next_(self, block_no=None, **options):
        allowed_params = ['depth']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/blocks/history/next/{block_no}"
        if block_no is not None:
            path = f"/api/core/blocks/history/next/{block_no}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreBlocksLatest:
    def __init__(self, client):
        self.client = client


    async def pools_(self, pool_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/blocks/latest/pools/{pool_hash}"
        if pool_hash is not None:
            path = f"/api/core/blocks/latest/pools/{pool_hash}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def transactions_(self, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/blocks/latest/transactions"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreBlocksPools:
    def __init__(self, client):
        self.client = client


    async def history_(self, pool_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/blocks/pools/{pool_hash}/history"
        if pool_hash is not None:
            path = f"/api/core/blocks/pools/{pool_hash}/history"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreEpochs:
    def __init__(self, client):
        self.client = client

        self.params = CoreEpochsParams(self.client)
        self.stakes = CoreEpochsStakes(self.client)
        self.latest = CoreEpochsLatest(self.client)

    async def latest_(self, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/epochs/latest"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def params_(self, epoch_no=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/epochs/params"
        if epoch_no is not None:
            path = f"/api/core/epochs/{epoch_no}/params"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreEpochsParams:
    def __init__(self, client):
        self.client = client


    async def latest_(self, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/epochs/params/latest"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreEpochsStakes:
    def __init__(self, client):
        self.client = client


    async def pools_(self, pool_hash=None, epoch_no=None, **options):
        allowed_params = ['page_no', 'page_size', 'order']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/epochs/stakes/pools/{pool_hash}"
        if pool_hash is not None:
            path = f"/api/core/epochs/stakes/pools/{pool_hash}"
        if epoch_no is not None:
            path = f"/api/core/epochs/{epoch_no}/stakes/pools/{pool_hash}"
        if pool_hash is not None:
            path = f"/api/core/epochs/{epoch_no}/stakes/pools/{pool_hash}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreEpochsLatest:
    def __init__(self, client):
        self.client = client

        self.stakes = CoreEpochsLatestStakes(self.client)

class CoreEpochsLatestStakes:
    def __init__(self, client):
        self.client = client


    async def pools_(self, pool_hash=None, **options):
        allowed_params = ['page_no', 'page_size', 'order']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/epochs/latest/stakes/pools/{pool_hash}"
        if pool_hash is not None:
            path = f"/api/core/epochs/latest/stakes/pools/{pool_hash}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CorePools:
    def __init__(self, client):
        self.client = client

        self.metadata = CorePoolsMetadata(self.client)
        self.relays = CorePoolsRelays(self.client)

    async def hashes_(self, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/pools/hashes"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def metadata_(self, pool_id=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/pools/metadata"
        if pool_id is not None:
            path = f"/api/core/pools/{pool_id}/metadata"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def offlinedata_(self, pool_id=None, ticker=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/pools/offlinedata"
        if pool_id is not None:
            path = f"/api/core/pools/{pool_id}/offlinedata"
        if ticker is not None:
            path = f"/api/core/pools/{ticker}/offlinedata"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def offlinefetcherrors_(self, pool_id=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/pools/offlinefetcherrors"
        if pool_id is not None:
            path = f"/api/core/pools/{pool_id}/offlinefetcherrors"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def updates_(self, pool_id=None, vrf_key_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/pools/updates"
        if pool_id is not None:
            path = f"/api/core/pools/{pool_id}/updates"
        if vrf_key_hash is not None:
            path = f"/api/core/pools/{vrf_key_hash}/updates"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CorePoolsMetadata:
    def __init__(self, client):
        self.client = client


    async def hashes_(self, meta_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/pools/metadata/hashes/{meta_hash}"
        if meta_hash is not None:
            path = f"/api/core/pools/metadata/hashes/{meta_hash}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def offlinedata_(self, meta_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/pools/metadata/{meta_hash}/offlinedata"
        if meta_hash is not None:
            path = f"/api/core/pools/metadata/{meta_hash}/offlinedata"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CorePoolsRelays:
    def __init__(self, client):
        self.client = client


    async def updates_(self, update_id=None, vrf_key_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/pools/relays/updates"
        if update_id is not None:
            path = f"/api/core/pools/relays/updates/{update_id}"
        if vrf_key_hash is not None:
            path = f"/api/core/pools/{vrf_key_hash}/relays/updates"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class CoreTransactions:
    def __init__(self, client):
        self.client = client


    async def utxos_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/utxos"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/utxos"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def stake_address_registrations_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/stake_address_registrations"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/stake_address_registrations"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def stake_address_delegations_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/stake_address_delegations"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/stake_address_delegations"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def withdrawals_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/withdrawals"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/withdrawals"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def treasury_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/treasury"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/treasury"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def reserves_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/reserves"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/reserves"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def param_proposals_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/param_proposals"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/param_proposals"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def retiring_pools_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/retiring_pools"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/retiring_pools"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def updating_pools_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/updating_pools"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/updating_pools"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def metadata_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/metadata"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/metadata"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def assetmints_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/assetmints"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/assetmints"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def redeemers_(self, transaction_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/core/transactions/{transaction_hash}/redeemers"
        if transaction_hash is not None:
            path = f"/api/core/transactions/{transaction_hash}/redeemers"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


