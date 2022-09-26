%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import (
    assert_not_zero,
    assert_not_equal,
    assert_nn,
    assert_nn_le,
    split_felt,
)
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import (
    library_call,
    get_caller_address,
    get_contract_address,
)
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_add, uint256_le, uint256_sub
from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721 import IERC721
from lib.cairo_contracts.src.openzeppelin.token.erc20.IERC20 import IERC20
from src.pools.IPool import NFT, PoolParams


// Events

@event
func TokenDeposit(nft: NFT) {
}

@event
func TokenWithdrawal(nft: NFT) {
}

@event
func PriceUpdate(new_price: Uint256) {
}

@event
func DeltaUpdate(new_delta: felt) {
}

@event
func PausePool(bool: felt) {
}


// Storage


@storage_var
func _pool_factory() -> (address: felt) {
}

@storage_var
func _current_price() -> (res: Uint256) {
}

@storage_var
func _delta() -> (res: felt) {
}

@storage_var
func _bonding_curve_class_hash() -> (res: felt) {
}

@storage_var
func _collection_by_id(int: felt) -> (address: felt) {
}

@storage_var
func _start_id_by_collection(address: felt) -> (int: felt) {
}

@storage_var
func _list_element_by_id(int: felt) -> (res: (token_id: Uint256, next_id: felt)) {
}

@storage_var
func _pool_paused() -> (bool: felt) {
}

@storage_var
func _eth_balance() -> (res: Uint256) {
}

@storage_var
func _erc20_address() -> (res: felt) {
}


// To do:
// Separate linked list functions and import as tested library in pool contract
// Refactor internal functions in SellPool with more purity for better testing after importing them


@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    factory_address: felt, bonding_curve_class_hash: felt, erc20_address: felt
) {
    alloc_locals;

    with_attr error_message("Address and class hash cannot be zero.") {
        assert_not_zero(factory_address * bonding_curve_class_hash * erc20_address);
    }
    _pool_factory.write(factory_address);
    _bonding_curve_class_hash.write(bonding_curve_class_hash);
    _erc20_address.write(erc20_address);

    return ();
}


@external
func setPoolParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    pool_params: PoolParams
) -> () {
    assert_only_owner();

    _current_price.write(pool_params.price);
    _delta.write(pool_params.delta);

    PriceUpdate.emit(pool_params.price);
    DeltaUpdate.emit(pool_params.delta);

    return ();
}


// Add NFTs to pool


@external
func addNftToPool{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len: felt, nft_array: NFT*
) -> () {
    assert_only_owner();

    _add_nft_to_pool(nft_array_len, nft_array);

    return ();
}


func _add_nft_to_pool{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len: felt, nft_array: NFT*
) -> () {
    alloc_locals;

    let (caller_address) = get_caller_address();
    let (contract_address) = get_contract_address();

    if (nft_array_len == 0) {
        return ();
    }

    const start_slot_collection_array = 0;
    const start_slot_element_list = 1;
    let (start_id) = _start_id_by_collection.read(nft_array[0].address);

    if (start_id == 0) {
        let (next_collection_id) = get_collection_count(start_slot_collection_array);
        _collection_by_id.write(next_collection_id, nft_array[0].address);

        let (next_free_slot) = find_next_free_slot(start_slot_element_list);
        _start_id_by_collection.write(nft_array[0].address, next_free_slot);
        _list_element_by_id.write(next_free_slot, (nft_array[0].id, 0));

        let (approved_address) = IERC721.getApproved(nft_array[0].address, nft_array[0].id);
        with_attr error_message("You have to sign approval transaction in your wallet.") {
            assert approved_address = contract_address;
        }
        IERC721.transferFrom(
            nft_array[0].address, caller_address, contract_address, nft_array[0].id
        );

        TokenDeposit.emit(nft_array[0]);

        return _add_nft_to_pool(nft_array_len - 1, nft_array + NFT.SIZE);
    }

    let (last_collection_element) = find_last_collection_element(start_id);
    let (next_free_slot) = find_next_free_slot(start_slot_element_list);
    let (last_token_id) = get_token_id(last_collection_element);

    _list_element_by_id.write(last_collection_element, (last_token_id, next_free_slot));
    _list_element_by_id.write(next_free_slot, (nft_array[0].id, 0));

    let (approved_address) = IERC721.getApproved(nft_array[0].address, nft_array[0].id);
    with_attr error_message("You have to sign approval transaction in your wallet.") {
        assert approved_address = contract_address;
    }
    IERC721.transferFrom(nft_array[0].address, caller_address, contract_address, nft_array[0].id);

    TokenDeposit.emit(nft_array[0]);

    return _add_nft_to_pool(nft_array_len - 1, nft_array + NFT.SIZE);
}


func find_next_free_slot{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_id: felt
) -> (next_free_slot: felt) {
    alloc_locals;
    let (s) = _list_element_by_id.read(current_id);

    local zero: Uint256 = Uint256(0, 0);
    let (is_zero) = uint256_eq(s[0], zero);

    if (is_zero == TRUE) {
        return (1,);
    }

    let (sum) = find_next_free_slot(current_id + 1);
    return (sum + 1,);
}


func find_last_collection_element{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_id: felt
) -> (last_collection_element: felt) {
    let (s) = _list_element_by_id.read(current_id);

    if (s[1] == 0) {
        return (current_id,);
    }

    return find_last_collection_element(s[1]);
}


func get_collection_count{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_id: felt
) -> (collection_count: felt) {
    let (s) = _collection_by_id.read(current_id);

    if (s == 0) {
        return (0,);
    }

    let (sum) = get_collection_count(current_id + 1);
    return (sum + 1,);
}


// Remove NFTs from pool


@external
func removeNftFromPool{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len: felt, nft_array: NFT*
) -> () {
    assert_only_owner();

    _remove_nft_from_pool(nft_array_len, nft_array);

    return ();
}


func _remove_nft_from_pool{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len: felt, nft_array: NFT*
) -> () {
    alloc_locals;

    let (caller_address) = get_caller_address();
    let (contract_address) = get_contract_address();

    if (nft_array_len == 0) {
        return ();
    }

    let (start_id) = _start_id_by_collection.read(nft_array[0].address);

    if (start_id == 0) {
        return ();
    }

    let (last_element, this_element) = find_element_to_be_removed(start_id, nft_array[0].id);

    if (last_element == 0) {
        _start_id_by_collection.write(nft_array[0].address, this_element);
        _list_element_by_id.write(start_id, (Uint256(0, 0), 0));

        let (token_owner) = IERC721.ownerOf(nft_array[0].address, nft_array[0].id);
        with_attr error_message("Pool is not the token owner") {
            assert token_owner = contract_address;
        }
        IERC721.transferFrom(
            nft_array[0].address, contract_address, caller_address, nft_array[0].id
        );

        TokenWithdrawal.emit(nft_array[0]);

        return _remove_nft_from_pool(nft_array_len - 1, nft_array + NFT.SIZE);
    }

    let (this_token_id) = get_token_id(this_element);
    let (last_token_id) = get_token_id(last_element);
    let (next_collection_slot) = get_next_collection_slot(this_element);

    _list_element_by_id.write(last_element, (last_token_id, next_collection_slot));
    _list_element_by_id.write(this_element, (Uint256(0, 0), 0));

    let (token_owner) = IERC721.ownerOf(nft_array[0].address, nft_array[0].id);
    with_attr error_message("Pool is not the token owner") {
        assert token_owner = contract_address;
    }
    IERC721.transferFrom(nft_array[0].address, contract_address, caller_address, nft_array[0].id);

    TokenWithdrawal.emit(nft_array[0]);

    return _remove_nft_from_pool(nft_array_len - 1, nft_array + NFT.SIZE);
}


func find_element_to_be_removed{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_id: felt, token_id: Uint256
) -> (last_element: felt, this_element: felt) {
    alloc_locals;
    let (last_element) = _list_element_by_id.read(current_id);
    let (this_element) = _list_element_by_id.read(last_element[1]);

    let (last_is_equal) = uint256_eq(last_element[0], token_id);
    if (last_is_equal == TRUE) {
        return (0, last_element[1]);
    }

    let (this_is_equal) = uint256_eq(this_element[0], token_id);
    if (this_is_equal == TRUE) {
        return (current_id, last_element[1]);
    }

    return find_element_to_be_removed(last_element[1], token_id);
}


// Get all pool assets


@view
func getAllCollections{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    collection_array_len: felt, collection_array: felt*
) {
    alloc_locals;
    let (collection_array: felt*) = alloc();

    tempvar array_index = 0;
    tempvar current_count = 0;
    let (collection_array_len) = populate_collections(collection_array, array_index, current_count);

    return (collection_array_len, collection_array);
}


func populate_collections{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    collection_array: felt*, array_index: felt, current_count: felt
) -> (collection_count: felt) {
    let (collection_element) = _collection_by_id.read(array_index);
    if (collection_element == 0) {
        return (current_count,);
    }

    let (start_id) = _start_id_by_collection.read(collection_element);
    if (start_id == 0) {
        return populate_collections(collection_array, array_index + 1, current_count);
    }

    collection_array[0] = collection_element;
    return populate_collections(collection_array + 1, array_index + 1, current_count + 1);
}


@view
func getAllNftsOfCollection{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    collection_address: felt
) -> (nft_id_list_len: felt, nft_id_list: Uint256*) {
    alloc_locals;
    let (nft_id_list: Uint256*) = alloc();

    let (start_id) = _start_id_by_collection.read(collection_address);

    if (start_id == 0) {
        return (0, nft_id_list);
    }

    tempvar list_index = 0;
    tempvar current_count = 0;
    let (nft_id_list_len) = populate_nfts(nft_id_list, list_index, start_id);

    return (nft_id_list_len, nft_id_list);
}


func populate_nfts{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_id_list: Uint256*, list_index: felt, current_id: felt
) -> (nft_count: felt) {
    let (s) = _list_element_by_id.read(current_id);
    assert nft_id_list[0] = s[0];

    if (s[1] == 0) {
        return (list_index + 1,);
    }

    return populate_nfts(nft_id_list + Uint256.SIZE, list_index + 1, s[1]);
}


// Swap NFTs


@external
func buyNfts{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_array_len: felt, nft_array: NFT*
) -> () {
    alloc_locals;

    assert_not_owner();

    let (is_paused) = _pool_paused.read();
    with_attr error_message("Pool is currently paused.") {
        assert is_paused = FALSE;
    }

    let (current_price) = _current_price.read();
    let (delta) = _delta.read();
    let (class_hash) = _bonding_curve_class_hash.read();

    let (calldata: felt*) = alloc();
    assert calldata[0] = nft_array_len;
    assert calldata[1] = current_price.low;
    assert calldata[2] = current_price.high;
    assert calldata[3] = delta;

    local function_selector_get_total_price = 162325169460772763346477168287411866553654952715135549492070698764789678722;

    let (retdata_size: felt, retdata: felt*) = library_call(
        class_hash=class_hash,
        function_selector=function_selector_get_total_price,
        calldata_size=4,
        calldata=calldata,
    );
    local total_price_low = retdata[0];
    local total_price_high = retdata[1];
    let total_price = Uint256(total_price_low, total_price_high);

    let (erc20_address) = _erc20_address.read();
    let (caller_address) = get_caller_address();
    let (contract_address) = get_contract_address();

    let (caller_balance) = IERC20.balanceOf(erc20_address, caller_address);
    let (sufficient_balance) = uint256_le(total_price, caller_balance);
    with_attr error_message("Your ETH balance is unsufficient.") {
        assert sufficient_balance = TRUE;
    }

    IERC20.transferFrom(erc20_address, caller_address, contract_address, total_price);

    let (old_eth_balance) = _eth_balance.read();
    let (new_eth_balance, _) = uint256_add(old_eth_balance, total_price);
    _eth_balance.write(new_eth_balance);

    local function_selector_get_new_price = 1427085065996622579194757518833714443103194349812573964832617639352675497406;

    let (retdata_size: felt, retdata: felt*) = library_call(
        class_hash=class_hash,
        function_selector=function_selector_get_new_price,
        calldata_size=4,
        calldata=calldata,
    );
    local new_price_low = retdata[0];
    local new_price_high = retdata[1];
    let new_price = Uint256(new_price_low, new_price_high);

    _current_price.write(new_price);
    PriceUpdate.emit(new_price);

    _remove_nft_from_pool(nft_array_len, nft_array);

    return ();
}


@external
func togglePause{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> () {
    assert_only_owner();

    let (is_paused) = _pool_paused.read();

    if (is_paused == FALSE) {
        _pool_paused.write(TRUE);
        PausePool.emit(TRUE);
    } else {
        _pool_paused.write(FALSE);
        PausePool.emit(FALSE);
    }

    return ();
}


@view
func isPaused{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    is_paused: felt
) {
    let (is_paused) = _pool_paused.read();

    return (is_paused,);
}


// Get pool configuration


@view
func getPoolFactory{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    pool_factory: felt
) {
    let (pool_factory) = _pool_factory.read();

    return (pool_factory,);
}


@view
func getPoolConfig{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    pool_params: PoolParams
) {
    let (current_price) = _current_price.read();
    let (delta) = _delta.read();
    let pool_params = PoolParams(price=current_price, delta=delta);

    return (pool_params,);
}


@view
func getNextPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    next_price: Uint256
) {
    alloc_locals;
    const number_items = 1;
    let (current_price) = _current_price.read();
    let (delta) = _delta.read();
    let (class_hash) = _bonding_curve_class_hash.read();

    let (calldata: felt*) = alloc();
    assert calldata[0] = number_items;
    assert calldata[1] = current_price.low;
    assert calldata[2] = current_price.high;
    assert calldata[3] = delta;

    local function_selector_get_new_price = 1427085065996622579194757518833714443103194349812573964832617639352675497406;

    let (retdata_size: felt, retdata: felt*) = library_call(
        class_hash=class_hash,
        function_selector=function_selector_get_new_price,
        calldata_size=4,
        calldata=calldata,
    );
    local next_price_low = retdata[0];
    local next_price_high = retdata[1];
    let next_price = Uint256(next_price_low, next_price_high);

    return (next_price,);
}


// Deposit and withdraw ETH


@external
func depositEth{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256
) -> () {
    alloc_locals;
    assert_only_owner();

    let (erc20_address) = _erc20_address.read();
    let (caller_address) = get_caller_address();
    let (contract_address) = get_contract_address();
    let (caller_balance) = IERC20.balanceOf(erc20_address, caller_address);
    let (sufficient_balance) = uint256_le(amount, caller_balance);
    with_attr error_message("Your ETH balance is unsufficient.") {
        assert sufficient_balance = TRUE;
    }

    IERC20.transferFrom(erc20_address, caller_address, contract_address, amount);

    let (old_balance) = _eth_balance.read();
    let (new_balance, _) = uint256_add(old_balance, amount);
    _eth_balance.write(new_balance);

    return ();
}


@external
func withdrawEth{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256
) -> () {
    alloc_locals;
    assert_only_owner();

    let (eth_balance) = _eth_balance.read();
    let (sufficient_balance) = uint256_le(amount, eth_balance);
    with_attr error_message("Pool ETH balance is unsufficient.") {
        assert sufficient_balance = TRUE;
    }

    let (erc20_address) = _erc20_address.read();
    let (caller_address) = get_caller_address();
    IERC20.transfer(erc20_address, caller_address, amount);

    let (new_balance) = uint256_sub(eth_balance, amount);
    _eth_balance.write(new_balance);

    return ();
}


@external
func withdrawAllEth{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> () {
    alloc_locals;
    assert_only_owner();

    let (eth_balance) = _eth_balance.read();

    local zero: Uint256 = Uint256(0, 0);
    let (is_zero) = uint256_eq(eth_balance, zero);
    with_attr error_message("Pool has no ETH to withdraw.") {
        assert is_zero = FALSE;
    }

    let (erc20_address) = _erc20_address.read();
    let (caller_address) = get_caller_address();
    IERC20.transfer(erc20_address, caller_address, eth_balance);

    _eth_balance.write(Uint256(0, 0));

    return ();
}


// Internal functions


func get_token_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_id: felt
) -> (res: Uint256) {
    let (x) = _list_element_by_id.read(current_id);
    return (x[0],);
}


func get_next_collection_slot{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_id: felt
) -> (res: felt) {
    let (x) = _list_element_by_id.read(current_id);
    return (x[1],);
}


func assert_only_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> () {
    let (caller_address) = get_caller_address();
    let (contract_address) = get_contract_address();
    let (contract_address_high, contract_address_low) = split_felt(contract_address);
    let (pool_factory_address) = _pool_factory.read();

    let (pool_owner) = IERC721.ownerOf(
        pool_factory_address, Uint256(contract_address_low, contract_address_high)
    );

    with_attr error_message("You must be the pool owner to call this function.") {
        assert caller_address = pool_owner;
    }

    return ();
}


func assert_not_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> () {
    let (caller_address) = get_caller_address();
    let (contract_address) = get_contract_address();
    let (contract_address_high, contract_address_low) = split_felt(contract_address);
    let (pool_factory_address) = _pool_factory.read();

    let (pool_owner) = IERC721.ownerOf(
        pool_factory_address, Uint256(contract_address_low, contract_address_high)
    );

    with_attr error_message("You cannot be the pool owner to call this function.") {
        assert_not_equal(caller_address, pool_owner);
    }

    return ();
}


// Helper functions for test purposes


@view
func getStartIdByCollection{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    collection_address: felt
) -> (res: felt) {
    let (res) = _start_id_by_collection.read(collection_address);
    return (res,);
}


@view
func getListElementById{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_id: felt
) -> (res: (Uint256, felt)) {
    let (x) = _list_element_by_id.read(current_id);
    return (x,);
}


@view
func getCollectionById{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    collection_id: felt
) -> (collection_address: felt) {
    let (x) = _collection_by_id.read(collection_id);
    return (x,);
}


@view
func getEthBalance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    eth_balance: Uint256
) {
    let (eth_balance) = _eth_balance.read();
    return (eth_balance,);
}
