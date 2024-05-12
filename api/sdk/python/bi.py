from utils import get_query_params

class Bi:
    def __init__(self, client):
        self.client = client

        self.addresses = BiAddresses(self.client)
        self.pools = BiPools(self.client)

class BiAddresses:
    def __init__(self, client):
        self.client = client


    async def stats_(self, address=None, **options):
        allowed_params = ['epoch_no_min', 'epoch_no_max', 'page_no', 'page_size', 'order']
        query_string = get_query_params(options, allowed_params)
        path = f"/api/bi/addresses/{address}/stats"
        if address is not None:
            path = f"/api/bi/addresses/{address}/stats"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class BiPools:
    def __init__(self, client):
        self.client = client

        self.stats = BiPoolsStats(self.client)

    async def stats_(self, pool_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/bi/pools/{pool_hash}/stats"
        if pool_hash is not None:
            path = f"/api/bi/pools/{pool_hash}/stats"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


class BiPoolsStats:
    def __init__(self, client):
        self.client = client


    async def epochs_(self, epoch_no=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/bi/pools/stats/epochs/{epoch_no}"
        if epoch_no is not None:
            path = f"/api/bi/pools/stats/epochs/{epoch_no}"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)

    async def lifetime_(self, pool_hash=None, **options):
        allowed_params = []
        query_string = get_query_params(options, allowed_params)
        path = f"/api/bi/pools/{pool_hash}/stats/lifetime"
        if pool_hash is not None:
            path = f"/api/bi/pools/{pool_hash}/stats/lifetime"
        # Append query string if it exists
        if query_string:
            path = f"{path}?{query_string}"
        return await self.client.getPrivate(path)


