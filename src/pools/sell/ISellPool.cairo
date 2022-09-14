%lang starknet

from starkware.cairo.common.uint256 import Uint256


struct NFT {
    address: felt,
    id: Uint256,
}

struct PoolParams {
    price: Uint256,
    delta: felt,
}


@contract_interface
namespace ISellPool {
    func setPoolParams(pool_params: PoolParams) -> () {
    }

    func getPoolFactory() -> (res: felt) {
    }

    func getPoolConfig() -> (pool_params: PoolParams) {
    }

    func getStartIdByCollection(collection_address: felt) -> (res: felt) {
    }

    func getListElementById(current_id: felt) -> (res: (Uint256, felt)) {
    }

    func addNftToPool(nft_array_len: felt, nft_array: NFT*) -> () {
    }

    func removeNftFromPool(nft_array_len: felt, nft_array: NFT*) -> () {
    }

    func getCollectionById(collection_id: felt) -> (collection_address: felt) {
    }

    func getAllCollections() -> (collection_array_len: felt, collection_array: felt*) {
    }

    func getAllNftsOfCollection(collection_address: felt) -> (nft_id_list_len: felt, nft_id_list: Uint256*) {
    }

    func buyNfts(nft_array_len: felt, nft_array: NFT*) -> () {
    }

    func togglePause() -> () {
    }

    func getEthBalance() -> (eth_balance: Uint256) {
    }

    func getNextPrice() -> (next_price: Uint256) {
    }

    func isPaused() -> (is_paused: felt) {
    }

    func mint(to: felt, token_id: Uint256) -> () {
    }

    func depositEth(amount: Uint256) -> () {
    }

    func withdrawEth(amount: Uint256) -> () {
    }

    func withdrawAllEth() -> () {
    }
}
