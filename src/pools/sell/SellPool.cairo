%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_not_equal, assert_nn, assert_nn_le, split_felt
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import library_call, get_caller_address, get_contract_address
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_signed_nn, uint256_add, uint256_signed_nn_le, uint256_neg, uint256_le

from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721 import IERC721
from lib.cairo_contracts.src.openzeppelin.token.erc20.IERC20 import IERC20


struct NFT:
    member address: felt
    member id: Uint256
end

struct PoolParams:
    member price: Uint256
    member delta: felt
end

struct PriceCalcParams:
    member tokens: felt
    member price: Uint256
    member delta: felt
end

# Events

@event
func TokenDeposit(nft: NFT):
end

@event
func TokenWithdrawal(nft: NFT):
end

@event
func PriceUpdate(new_price: Uint256):
end

@event
func DeltaUpdate(new_delta: felt):
end

@event
func PausePool(bool: felt):
end


# Storage

@storage_var
func pool_factory() -> (address: felt):
end 

@storage_var
func current_price() -> (res: Uint256):
end 

@storage_var
func delta() -> (res: felt):
end 

@storage_var
func bonding_curve_class_hash() -> (res: felt):
end 

@storage_var
func collection_by_id(int: felt) -> (address: felt):
end

@storage_var
func start_id_by_collection(address: felt) -> (int: felt):
end

@storage_var
func list_element_by_id(int: felt) -> (res: (token_id: Uint256, next_id: felt)):
end

@storage_var
func pool_paused() -> (bool: felt):
end 

@storage_var
func eth_balance() -> (res: Uint256):
end

@storage_var
func erc20_address() -> (res: felt):
end


# To do:
# Separate linked list functions and import as tested library in pool contract
# Refactor internal functions in SellPool with more purity for better testing after importing them


@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _factory_address: felt,
        _bonding_curve_class_hash: felt,
        _erc20_address: felt,
        _pool_params: PoolParams
    ):
    alloc_locals

    with_attr error_message("Address and class hash cannot be zero."):
        assert_not_zero(_factory_address * _bonding_curve_class_hash * _erc20_address)
    end
    pool_factory.write(_factory_address)
    bonding_curve_class_hash.write(_bonding_curve_class_hash)
    erc20_address.write(_erc20_address)

    current_price.write(_pool_params.price)
    delta.write(_pool_params.delta)

    return ()
end


# Add NFTs to pool

@external
func addNftToPool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():

    #assert_only_owner()
    _add_nft_to_pool(_nft_array_len, _nft_array)

    return ()

end


func _add_nft_to_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():
    alloc_locals

    let (caller_address) = get_caller_address()
    let (contract_address) = get_contract_address()

    if _nft_array_len == 0:
        return ()
    end

    const start_slot_collection_array = 0
    const start_slot_element_list = 1
    let (start_id) = start_id_by_collection.read(_nft_array[0].address)

    if start_id == 0:
        let (next_collection_id) = get_collection_count(start_slot_collection_array)
        collection_by_id.write(next_collection_id, _nft_array[0].address)

        let (next_free_slot) = find_next_free_slot(start_slot_element_list)
        start_id_by_collection.write(_nft_array[0].address, next_free_slot)
        list_element_by_id.write(next_free_slot, (_nft_array[0].id, 0))

        let (approved_address) = IERC721.getApproved(_nft_array[0].address, _nft_array[0].id)
        with_attr error_message("You have to sign approval transaction in your wallet."):
            assert approved_address = contract_address
        end
        IERC721.transferFrom(_nft_array[0].address, caller_address, contract_address, _nft_array[0].id)

        TokenDeposit.emit(_nft_array[0])

        return _add_nft_to_pool(_nft_array_len - 1, _nft_array + NFT.SIZE)
    end

    let (last_collection_element) = find_last_collection_element(start_id)
    let (next_free_slot) = find_next_free_slot(start_slot_element_list)
    let (last_token_id) = get_token_id(last_collection_element)

    list_element_by_id.write(last_collection_element, (last_token_id, next_free_slot))
    list_element_by_id.write(next_free_slot, (_nft_array[0].id, 0))

    let (approved_address) = IERC721.getApproved(_nft_array[0].address, _nft_array[0].id)
    with_attr error_message("You have to sign approval transaction in your wallet."):
        assert approved_address = contract_address
    end
    IERC721.transferFrom(_nft_array[0].address, caller_address, contract_address, _nft_array[0].id)
    
    TokenDeposit.emit(_nft_array[0])

    return _add_nft_to_pool(_nft_array_len - 1, _nft_array + NFT.SIZE)

end


func find_next_free_slot{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (
        _next_free_slot: felt
    ):
    alloc_locals
    let (s) = list_element_by_id.read(_current_id)

    local zero: Uint256 = Uint256(0, 0)
    let (is_zero) = uint256_eq(s[0], zero)

    if is_zero == TRUE:
        return (1)
    end 

    let (sum) = find_next_free_slot(_current_id + 1)
    return (sum + 1)

end


func find_last_collection_element{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (
        _last_collection_element: felt
    ):

    let (s) = list_element_by_id.read(_current_id)

    if s[1] == 0:
        return (_current_id)
    end

    return find_last_collection_element(s[1])

end


func get_collection_count{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (
        _collection_count: felt
    ):

    let (s) = collection_by_id.read(_current_id)

    if s == 0:
        return (0)
    end

    let (sum) = get_collection_count(_current_id + 1)
    return (sum + 1)

end


# Remove NFTs from pool

@external
func removeNftFromPool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():

    #assert_only_owner()
    _remove_nft_from_pool(_nft_array_len, _nft_array)

    return ()

end


func _remove_nft_from_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():
    alloc_locals

    let (caller_address) = get_caller_address()
    let (contract_address) = get_contract_address()

    if _nft_array_len == 0:
        return ()
    end

    let (start_id) = start_id_by_collection.read(_nft_array[0].address)

    if start_id == 0:
        return ()
    end

    let (last_element, this_element) = find_element_to_be_removed(start_id, _nft_array[0].id)

    if last_element == 0: 
        start_id_by_collection.write(_nft_array[0].address, this_element)
        list_element_by_id.write(start_id, (Uint256(0,0), 0))

        let (token_owner) = IERC721.ownerOf(_nft_array[0].address, _nft_array[0].id)
        with_attr error_message("Pool is not the token owner"):
            assert token_owner = contract_address
        end
        IERC721.transferFrom(_nft_array[0].address, contract_address, caller_address, _nft_array[0].id)
        
        TokenWithdrawal.emit(_nft_array[0])

        return _remove_nft_from_pool(_nft_array_len - 1, _nft_array + NFT.SIZE)
    end

    let (this_token_id) = get_token_id(this_element)
    let (last_token_id) = get_token_id(last_element)
    let (next_collection_slot) = get_next_collection_slot(this_element)

    list_element_by_id.write(last_element, (last_token_id, next_collection_slot))
    list_element_by_id.write(this_element, (Uint256(0,0), 0))

    let (token_owner) = IERC721.ownerOf(_nft_array[0].address, _nft_array[0].id)
    with_attr error_message("Pool is not the token owner"):
        assert token_owner = contract_address
    end
    IERC721.transferFrom(_nft_array[0].address, contract_address, caller_address, _nft_array[0].id)

    TokenWithdrawal.emit(_nft_array[0])

    return _remove_nft_from_pool(_nft_array_len - 1, _nft_array + NFT.SIZE)

end


func find_element_to_be_removed{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt,
        _token_id: Uint256
    ) -> (
        _last_element: felt,
        _this_element: felt
    ):
    alloc_locals
    let (_last_element) = list_element_by_id.read(_current_id)
    let (_this_element) = list_element_by_id.read(_last_element[1])

    let (last_is_equal) = uint256_eq(_last_element[0], _token_id)
    if last_is_equal == TRUE:
        return (0, _last_element[1])
    end 

    let (this_is_equal) = uint256_eq(_this_element[0], _token_id)
    if this_is_equal == TRUE:
        return (_current_id, _last_element[1])
    end 

    return find_element_to_be_removed(_last_element[1], _token_id)

end


# Edit pool 


@external
func editPool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _new_pool_params: PoolParams
    ) -> ():
    #assert_only_owner()

    # To do: Check if price and delta were actually changed
    current_price.write(_new_pool_params.price)
    delta.write(_new_pool_params.delta)

    PriceUpdate.emit(_new_pool_params.price)
    DeltaUpdate.emit(_new_pool_params.delta)

    return ()
end


# Get all pool assets


@view
func getAllCollections{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (
        _collection_array_len: felt,
        _collection_array: felt*
    ):
    alloc_locals
    let (collection_array: felt*) = alloc()

    tempvar array_index = 0
    tempvar current_count = 0
    let (collection_array_len) = populate_collections(collection_array, array_index, current_count)

    return (collection_array_len, collection_array)

end


func populate_collections{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _collection_array: felt*,
        _array_index: felt,
        _current_count: felt
    ) -> (
        _collection_count: felt
    ):
    let (_collection_element) = collection_by_id.read(_array_index)
    if _collection_element == 0:
        return (_current_count)
    end

    let (_start_id) = start_id_by_collection.read(_collection_element)
    if _start_id == 0: 
        return populate_collections(_collection_array, _array_index + 1, _current_count)
    end

    _collection_array[0] = _collection_element
    return populate_collections(_collection_array + 1, _array_index + 1, _current_count + 1)

end


@view
func getAllNftsOfCollection{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _collection_address: felt
    ) -> (
        _nft_id_list_len: felt,
        _nft_id_list: Uint256*
    ):
    alloc_locals
    let (_nft_id_list: Uint256*) = alloc()

    # with_attr error_message("Collection address cannot be negative."):
    #     assert_nn(_collection_address)
    # end

    let (start_id) = start_id_by_collection.read(_collection_address)

    if start_id == 0:
        return (0, _nft_id_list)
    end

    tempvar list_index = 0
    tempvar current_count = 0
    let (_nft_id_list_len) = populate_nfts(_nft_id_list, list_index, start_id)

    return (_nft_id_list_len, _nft_id_list)

end


func populate_nfts{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_id_list: Uint256*,
        _list_index: felt,
        _current_id: felt
    ) -> (
        _nft_count: felt
    ):

    let (s) = list_element_by_id.read(_current_id)
    assert _nft_id_list[0] = s[0]

    if s[1] == 0:
        return (_list_index + 1)
    end

    return populate_nfts(_nft_id_list + Uint256.SIZE, _list_index + 1, s[1])

end


# Swap NFTs

@external
func buyNfts{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():
    alloc_locals

    #assert_not_owner()

    let (_is_paused) = pool_paused.read()
    with_attr error_message("Pool is currently paused."):
        assert _is_paused = FALSE
    end

    let (_current_price) = current_price.read()
    let (_delta) = delta.read()
    let (_class_hash) = bonding_curve_class_hash.read()

    let (_calldata: PriceCalcParams*) = alloc()
    assert _calldata[0] = PriceCalcParams(tokens=_nft_array_len, price=_current_price, delta=_delta)
    
    local _function_selector_get_total_price = 162325169460772763346477168287411866553654952715135549492070698764789678722
    
    let (retdata_size: felt, retdata: felt*) = library_call(
        class_hash=_class_hash, 
        function_selector=_function_selector_get_total_price,
        calldata_size=4,
        calldata=_calldata
    )
    local _total_price_low = retdata[0]
    local _total_price_high = retdata[1]
    let _total_price = Uint256(_total_price_low, _total_price_high)

    let (_erc20_address) = erc20_address.read()
    let (_caller_address) = get_caller_address()
    let (_contract_address) = get_contract_address()

    let (_caller_balance) = IERC20.balanceOf(_erc20_address, _caller_address)
    let (_sufficient_balance) = uint256_le(_total_price, _caller_balance)
    with_attr error_message("Your ETH balance is unsufficient."):
        assert _sufficient_balance = TRUE
    end

    IERC20.transferFrom(_erc20_address, _caller_address, _contract_address, _total_price)

    let (_old_eth_balance) = eth_balance.read()
    let (_new_eth_balance, _) = uint256_add(_old_eth_balance, _total_price)
    eth_balance.write(_new_eth_balance)

    local _function_selector_get_new_price = 1427085065996622579194757518833714443103194349812573964832617639352675497406

    let (retdata_size: felt, retdata: felt*) = library_call(
        class_hash=_class_hash, 
        function_selector=_function_selector_get_new_price,
        calldata_size=4,
        calldata=_calldata
    )
    local _new_price_low = retdata[0]
    local _new_price_high = retdata[1]
    let _new_price = Uint256(_new_price_low, _new_price_high)

    current_price.write(_new_price)
    PriceUpdate.emit(_new_price)

    _remove_nft_from_pool(_nft_array_len, _nft_array)
    
    return ()
end


@external
func togglePause{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> ():
    #assert_only_owner()

    let (_is_paused) = pool_paused.read()
    
    if _is_paused == FALSE:
        pool_paused.write(TRUE)
        PausePool.emit(TRUE)
    else:
        pool_paused.write(FALSE)
        PausePool.emit(FALSE)
    end

    return ()
end


@view
func isPaused{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (
        _is_paused: felt
    ):
    let (_is_paused) = pool_paused.read()
    
    return (_is_paused)
end


# Get pool configuration


@view
func getPoolFactory{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }() -> (
        _pool_factory: felt
    ):
    let (_pool_factory) = pool_factory.read()

    return (_pool_factory)
end


@view
func getPoolConfig{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (
        _pool_params: PoolParams
    ):
    let (_current_price) = current_price.read()
    let (_delta) = delta.read()
    let _pool_params = PoolParams(price = _current_price, delta = _delta)

    return (_pool_params)
end


@view
func getNextPrice{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (
        _next_price: Uint256
    ):
    alloc_locals
    const _number_items = 1
    let (_current_price) = current_price.read()
    let (_delta) = delta.read()
    let (_class_hash) = bonding_curve_class_hash.read()

    let (_calldata: PriceCalcParams*) = alloc()
    assert _calldata[0] = PriceCalcParams(tokens=_number_items, price=_current_price, delta=_delta)

    local _function_selector_get_new_price = 1427085065996622579194757518833714443103194349812573964832617639352675497406

    let (retdata_size: felt, retdata: felt*) = library_call(
        class_hash=_class_hash, 
        function_selector=_function_selector_get_new_price,
        calldata_size=4,
        calldata=_calldata
    )
    local _next_price_low = retdata[0]
    local _next_price_high = retdata[1]
    let _next_price = Uint256(_next_price_low, _next_price_high)

    return (_next_price)
end


# Deposit and withdraw ETH 


@external
func deposit_eth{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(_amount: Uint256) -> ():
    alloc_locals
    #assert_only_owner()
    
    # To do:
    # Call ERC20 contract to check if balanceOf (owner) > _amount
    # Check if pool is approved for amount
    # -> Transfer ETH amount from owner to pool address

    let (_old_balance) = eth_balance.read()
    let (_new_balance, _) = uint256_add(_old_balance, _amount)
    eth_balance.write(_new_balance)

    return ()
end


@external
func withdraw_eth{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(_amount: Uint256) -> ():
    alloc_locals
    #assert_only_owner()

    let (_eth_balance) = eth_balance.read()
    let (_sufficient_eth) = uint256_signed_nn_le(_amount, _eth_balance)
    with_attr error_message("Your ETH balance is not sufficient"):
        assert _sufficient_eth = TRUE
    end

    # To do:
    # Call ERC20 contract to check if balanceOf (pool) > _amount
    # -> Transfer ETH amount from pool to owner address

    #let (_old_balance) = eth_balance.read()
    let (_new_balance, _) = uint256_add(_eth_balance, _amount)
    eth_balance.write(_new_balance)

    return ()
end


@external
func withdraw_all_eth{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> ():
    alloc_locals
    #assert_only_owner()

    let (_eth_balance) = eth_balance.read()

    local zero: Uint256 = Uint256(0, 0)
    let (is_zero) = uint256_eq(_eth_balance, zero)
    with_attr error_message("You have no ETH to withdraw."):
        assert is_zero = FALSE
    end


    # To do:
    # Call ERC20 contract to check if balanceOf (pool) = _eth_balance
    # -> Transfer whole ETH balance from pool to owner address

    eth_balance.write(Uint256(0, 0))

    return ()
end


# Internal functions


func get_token_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (res: Uint256):
  
    let (x) = list_element_by_id.read(_current_id)
    return (x[0])
end


func get_next_collection_slot{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (res: felt):
    
    let (x) = list_element_by_id.read(_current_id)
    return (x[1])
end


func assert_only_owner{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> ():
    let (_caller_address) = get_caller_address()
    let (_contract_address) = get_contract_address()
    let (_contract_address_high, _contract_address_low) = split_felt(_contract_address)
    let (_pool_factory_address) = pool_factory.read()

    let (_pool_owner) = IERC721.ownerOf(_pool_factory_address, Uint256(_contract_address_low, _contract_address_high))
    
    with_attr error_message("You must be the pool owner to call this function."):
        assert _caller_address = _pool_owner
    end

    return ()
end


func assert_not_owner{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> ():
    let (_caller_address) = get_caller_address()
    let (_contract_address) = get_contract_address()
    let (_contract_address_high, _contract_address_low) = split_felt(_contract_address)
    let (_pool_factory_address) = pool_factory.read()

    let (_pool_owner) = IERC721.ownerOf(_pool_factory_address, Uint256(_contract_address_low, _contract_address_high))
    
    with_attr error_message("You cannot be the pool owner to call this function."):
        assert_not_equal(_caller_address, _pool_owner)
    end

    return ()
end


# Helper functions for test purposes


@view
func getStartIdByCollection{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _collection_address: felt
    ) -> (res: felt):
    
    let (res) = start_id_by_collection.read(_collection_address)
    return (res)
end


@view
func getListElementById{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (res: (Uint256, felt)):
    
    let (x) = list_element_by_id.read(_current_id)
    return (x)
end


@view
func getCollectionById{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _collection_id: felt
    ) -> (_collection_address: felt):
    
    let (x) = collection_by_id.read(_collection_id)
    return (x)
end


@view
func getEthBalance{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (_eth_balance: Uint256):
    
    let (_eth_balance) = eth_balance.read()
    return (_eth_balance)
end