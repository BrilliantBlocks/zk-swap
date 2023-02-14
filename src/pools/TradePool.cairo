%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address,
    library_call
)
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import (
    Uint256, 
    uint256_le, 
    uint256_sub,
    uint256_add
)

from lib.cairo_contracts.src.openzeppelin.token.erc20.IERC20 import IERC20

from src.utils.Constants import FunctionSelector
from src.pools.IPool import NFT
from src.pools.Pool import (
    PriceUpdate
)
from src.pools.Pool import (
    _current_price,
    _delta,
    _bonding_curve_class_hash,
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
    _add_nft_to_pool,
    removeNftFromPool,
    _remove_nft_from_pool,
    getAllCollections,
    getAllNftsOfCollection,
    assert_collections_supported,
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
    assert_not_owner
)


@external
func sellNfts{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len: felt, nft_array: NFT*
) -> () {
    alloc_locals;
    assert_not_owner();

    let (is_paused) = _pool_paused.read();
    with_attr error_message("Pool must not be paused") {
        assert is_paused = FALSE;
    }

    assert_collections_supported(nft_array_len, nft_array);

    let (total_price) = get_total_price(nft_array_len);
    let (new_price) = get_next_price(nft_array_len);

    let (eth_balance) = _eth_balance.read();
    let (sufficient_balance) = uint256_le(total_price, eth_balance);
    with_attr error_message("Pool ETH balance is not sufficient") {
        assert sufficient_balance = TRUE;
    }

    let (erc20_address) = _erc20_address.read();
    let (caller_address) = get_caller_address();

    IERC20.transfer(erc20_address, caller_address, total_price);

    let (new_eth_balance) = uint256_sub(eth_balance, total_price);
    _eth_balance.write(new_eth_balance);

    _current_price.write(new_price);
    PriceUpdate.emit(new_price);

    _add_nft_to_pool(nft_array_len, nft_array);

    return ();
}


@external
func buyNfts{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len: felt, nft_array: NFT*
) -> () {
    alloc_locals;
    assert_not_owner();

    let (is_paused) = _pool_paused.read();
    with_attr error_message("Pool must not be paused") {
        assert is_paused = FALSE;
    }

    let (total_price) = get_total_price(nft_array_len);
    let (new_price) = get_next_price(nft_array_len);

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

    _current_price.write(new_price);
    PriceUpdate.emit(new_price);

    _remove_nft_from_pool(nft_array_len, nft_array);

    return ();
}


func get_total_price{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len
) -> (total_price: Uint256) {
    alloc_locals;
    let (current_price) = _current_price.read();
    let (delta) = _delta.read();
    let (class_hash) = _bonding_curve_class_hash.read();

    let (calldata: felt*) = alloc();
    assert calldata[0] = nft_array_len;
    assert calldata[1] = current_price.low;
    assert calldata[2] = current_price.high;
    assert calldata[3] = delta;

    let (retdata_size: felt, retdata: felt*) = library_call(
        class_hash=class_hash,
        function_selector=FunctionSelector.get_total_price,
        calldata_size=4,
        calldata=calldata,
    );
    local total_price_low = retdata[0];
    local total_price_high = retdata[1];
    let total_price = Uint256(total_price_low, total_price_high);
    return (total_price,);
}


func get_next_price{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len
) -> (next_price: Uint256) {
    alloc_locals;
    let (current_price) = _current_price.read();
    let (delta) = _delta.read();
    let (class_hash) = _bonding_curve_class_hash.read();

    let (calldata: felt*) = alloc();
    assert calldata[0] = nft_array_len;
    assert calldata[1] = current_price.low;
    assert calldata[2] = current_price.high;
    assert calldata[3] = delta;

    let (retdata_size: felt, retdata: felt*) = library_call(
        class_hash=class_hash,
        function_selector=FunctionSelector.get_next_price,
        calldata_size=4,
        calldata=calldata,
    );
    local next_price_low = retdata[0];
    local next_price_high = retdata[1];
    let next_price = Uint256(next_price_low, next_price_high);
    return (next_price,);
}