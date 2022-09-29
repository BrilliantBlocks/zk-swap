%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address
)
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.uint256 import (
    Uint256, 
    uint256_add,
    uint256_le
)

from lib.cairo_contracts.src.openzeppelin.token.erc20.IERC20 import IERC20

from src.pools.IPool import NFT
from src.pools.Pool import (
    PriceUpdate
)
from src.pools.Pool import (
    _current_price,
    _pool_paused,
    _eth_balance,
    _erc20_address,
)
from src.pools.Pool import (
    constructor,
    setPoolParams,
    addSupportedCollections,
    removeSupportedCollections,
    addNftToPool,
    removeNftFromPool,
    _remove_nft_from_pool,
    getAllCollections,
    getAllNftsOfCollection,
    get_total_price,
    get_next_price,
    togglePause,
    isPaused,
    getPoolFactory,
    getPoolConfig,
    getNextPrice,
    getTokenPrices,
    depositEth,
    withdrawEth,
    withdrawAllEth,
    getStartIdByCollection,
    getListElementById,
    getCollectionById,
    getEthBalance,
    checkCollectionSupport,
    assert_only_owner,
    assert_not_owner,
    assert_positive_price
)


@external
func buyNfts{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len: felt, nft_array: NFT*
) -> () {

    assert_not_owner();

    let (is_paused) = _pool_paused.read();
    with_attr error_message("Pool must not be paused") {
        assert is_paused = FALSE;
    }

    assert_positive_price(nft_array_len);

    let (total_price) = get_total_price(nft_array_len);

    let (erc20_address) = _erc20_address.read();
    let (caller_address) = get_caller_address();
    let (contract_address) = get_contract_address();

    let (caller_balance) = IERC20.balanceOf(erc20_address, caller_address);
    let (sufficient_balance) = uint256_le(total_price, caller_balance);
    with_attr error_message("Your ETH balance is not sufficient") {
        assert sufficient_balance = TRUE;
    }

    IERC20.transferFrom(erc20_address, caller_address, contract_address, total_price);

    let (old_eth_balance) = _eth_balance.read();
    let (new_eth_balance, _) = uint256_add(old_eth_balance, total_price);
    _eth_balance.write(new_eth_balance);

    let (new_price) = get_next_price(nft_array_len);

    _current_price.write(new_price);
    PriceUpdate.emit(new_price);

    _remove_nft_from_pool(nft_array_len, nft_array);

    return ();
}