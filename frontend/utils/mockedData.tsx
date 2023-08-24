import { TableCollection } from "../pages";


export const generateMockedTableCollection = (): TableCollection[] => {
    const projects = [
      { name: "XPlorer", volume: 500, bestOffer: 2, poolDelta: 1, nextPrice: 3 },
      { name: "StarkPunks", volume: 150, bestOffer: 0.5, poolDelta: 0.8, nextPrice: 1.3 },
      { name: "briq Sets", volume: 300, bestOffer: 1, poolDelta: 1.2, nextPrice: 2.2 },
      { name: "Starknet.id", volume: 100, bestOffer: 0.3, poolDelta: 0.5, nextPrice: 0.8 },
      { name: "StarkRock", volume: 180, bestOffer: 0.6, poolDelta: 0.8, nextPrice: 1.4 },
      { name: "Starknet Quest", volume: 120, bestOffer: 0.2, poolDelta: 0.4, nextPrice: 0.6 },
    ];
  
    return projects.map((project, index) => ({
      collectionAddr: generateRandomEthereumAddress(),
      poolAddr: generateRandomEthereumAddress(),
      name: project.name,
      nftsMetadata: [
        {
          tokenId: `${index * 1000 + 1}`,
          nftMetadata: `Description for ${project.name} NFT #${index * 1000 + 1}`
        },
        {
          tokenId: `${index * 1000 + 2}`,
          nftMetadata: `Description for ${project.name} NFT #${index * 1000 + 2}`
        },
      ],
      volume: project.volume,
      bestOffer: project.bestOffer,
      poolDelta: project.poolDelta,
      nextPrice: project.nextPrice
    }));
};

const generateRandomEthereumAddress = () => {
    return '0x' + [...Array(40)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');
};


export const mockedNfts: any = [
  {
    Metadata: {
      "id": 1,
      "name": "Example NFT 1",
      "image": "http://image.nft.brilliantblocks.io/test/1.jpg"
    },
    TokenId: 1,
    nextPrice: 1,
    poolDelta: 2
  },
  {
    Metadata: {
      "id": 2,
      "name": "Example NFT 2",
      "image": "http://image.nft.brilliantblocks.io/test/2.jpg"
    },
    TokenId: 2,
    nextPrice: 1,
    poolDelta: 2
  },
  {
    Metadata: {
      "id": 3,
      "name": "Example NFT 3",
      "image": "http://image.nft.brilliantblocks.io/test/3.jpg",
    },
    TokenId: 3,
    nextPrice: 1,
    poolDelta: 2
  },
  {
    Metadata: {
      "id": 4,
      "name": "Example NFT 4",
      "image": "http://image.nft.brilliantblocks.io/test/4.jpg"
    },
    TokenId: 4,
    nextPrice: 1,
    poolDelta: 2
  },
  {
    Metadata: {
      "id": 5,
      "name": "Example NFT 5",
      "image": "http://image.nft.brilliantblocks.io/test/5.jpg"
    },
    TokenId: 5,
    nextPrice: 1,
    poolDelta: 2
  }
]
  