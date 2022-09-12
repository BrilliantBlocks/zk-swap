%lang starknet

from starkware.cairo.common.uint256 import Uint256


struct NFT:
    member address: felt
    member id: Uint256
end

struct PoolParams:
    member price: Uint256
    member delta: felt
end


@contract_interface
namespace ISellPool:
    
    func setPoolParams(pool_params: PoolParams) -> ():
    end

    func getPoolFactory() -> (res : felt):
    end

    func getPoolConfig() -> (pool_params: PoolParams):
    end

    func getStartIdByCollection(collection_address: felt) -> (res: felt):
    end

    func getListElementById(current_id: felt) -> (res: (Uint256, felt)):
    end

    func addNftToPool(nft_array_len: felt,  nft_array: NFT*) -> ():
    end

    func removeNftFromPool(nft_array_len: felt,  nft_array: NFT*) -> ():
    end

    func getCollectionById(collection_id: felt) -> (collection_address: felt):
    end

    func getAllCollections() -> (collection_array_len: felt, collection_array: felt*):
    end

    func getAllNftsOfCollection(collection_address: felt) -> (nft_id_list_len: felt, nft_id_list: Uint256*):
    end

    func buyNfts(nft_array_len: felt,  nft_array: NFT*) -> ():
    end

    func togglePause() -> ():
    end

    func getEthBalance() -> (eth_balance : Uint256):
    end

    func getNextPrice() -> (next_price : Uint256):
    end

    func isPaused() -> (is_paused : felt):
    end

    func mint(to: felt, token_id: Uint256) -> ():
    end

    func depositEth(amount: Uint256) -> ():
    end

    func withdrawEth(amount: Uint256) -> ():
    end

    func withdrawAllEth() -> ():
    end

end