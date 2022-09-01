%lang starknet

from starkware.cairo.common.uint256 import Uint256

from src.pools.sell.SellPool import NFT, PoolParams

@contract_interface
namespace ISellPool:
    
    func getPoolFactory() -> (res : felt):
    end

    func getPoolConfig() -> (_pool_params: PoolParams):
    end

    func getStartIdByCollection(_collection_address: felt) -> (res: felt):
    end

    func getListElementById(_current_id: felt) -> (res: (Uint256, felt)):
    end

    func addNftToPool(_nft_array_len: felt,  _nft_array: NFT*) -> ():
    end

    func removeNftFromPool(_nft_array_len: felt,  _nft_array: NFT*) -> ():
    end

    func editPool(_new_pool_params: PoolParams) -> ():
    end

    func getCollectionById(_collection_id: felt) -> (_collection_address: felt):
    end

    func getAllCollections() -> (_collection_array_len: felt, _collection_array: felt*):
    end

    func getAllNftsOfCollection(_collection_address: felt) -> (_nft_id_list_len: felt, _nft_id_list: Uint256*):
    end

    func buyNfts(_nft_array_len: felt,  _nft_array: NFT*) -> ():
    end

    func togglePause() -> ():
    end

    func getEthBalance() -> (_eth_balance : felt):
    end

    func getNextPrice() -> (_next_price : felt):
    end

    func isPaused() -> (_is_paused : felt):
    end

    func mint(to: felt, token_id: Uint256) -> ():
    end

end