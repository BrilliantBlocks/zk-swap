export const sortCollectionAndPoolAddress = async() => {
    const dataFromDB: any = localStorage.getItem('CollectionsFromAllPools')
    const data = JSON.parse(dataFromDB)
    
    let collections: Array<any> = []
    let pools: Array<any> = []

    data.forEach((element: any, position: any) => {
        if(position % 2 == 0) {
            collections.push(element)
        } else {
            pools.push(element)
        }
    })

    localStorage.setItem('CollectionsAddresses', JSON.stringify(collections))
    localStorage.setItem('PoolsAddresses', JSON.stringify(pools))
}