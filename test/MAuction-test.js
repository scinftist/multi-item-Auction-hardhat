const { ethers } = require("hardhat")
const { assert, expect } = require("chai")

let _verbose = false
describe("testin multi Item Simultaneous auction initialization", () => {
    let MAH, Mtoken, MAHfactory, MTokenFactory
    const _itemInAuction = 5
    beforeEach(async function () {
        MAHfactory = await ethers.getContractFactory("MultiAuctionHouse")
        MAH = await MAHfactory.deploy()
        // console.log(`this is the contract address ${MAH.address}`)
        // const acclist = await ethers.getSigners()
        MTokenFactory = await ethers.getContractFactory("MToken")

        Mtoken = await MTokenFactory.deploy()
        await Mtoken.transferOwnership(MAH.address)
        await MAH.initialize(Mtoken.address, _itemInAuction, 0, 0, 0, 100)
    })
    it("balance should be equal to number of Tokens in Auction", async () => {
        const _MtokenBalance = await Mtoken.balanceOf(MAH.address)
        assert.equal(_MtokenBalance, _itemInAuction)
    })

    // await
})

describe("testin multi Item Simultaneous auction bidding", () => {
    let MAH, Mtoken, MAHfactory, MTokenFactory
    const _itemInAuction = 5
    let acclist
    beforeEach(async function () {
        MAHfactory = await ethers.getContractFactory("MultiAuctionHouse")
        MAH = await MAHfactory.deploy()
        // console.log(`this is the contract address ${MAH.address}`)
        // const acclist = await ethers.getSigners()
        MTokenFactory = await ethers.getContractFactory("MToken")

        Mtoken = await MTokenFactory.deploy()
        await Mtoken.transferOwnership(MAH.address)
        await MAH.initialize(Mtoken.address, _itemInAuction, 0, 0, 2, 300)
        acclist = await ethers.getSigners()
    })
    for (j = 0; j < 10; j++) {
        it("biding", async () => {
            // const _MtokenBalance = await Mtoken.balanceOf(MAH.address)
            // assert.equal(_MtokenBalance, _itemInAuction)
            let _posToBid
            let _signer
            let _bidable
            let _auctionNumber
            _auctionNumber = await MAH.getCurrentAuctionNumber()
            for (i = 0; i < 10; i++) {
                let val = getRandomIntInclusive(1, 100)
                _signer = await ethers.getSigner(acclist[i].address)
                _bidable = await MAH.isBidable(_auctionNumber, val.toString())
                if (_verbose) console.log(`val : ${val}`)
                if (!_bidable) {
                    _posToBid = await MAH.findPos(_auctionNumber, val)
                    if (_verbose)
                        console.log(
                            `${val} is bidable? ${_bidable} at pos : ${_posToBid}`
                        )
                    await expect(
                        MAH.connect(_signer).createBid(
                            _auctionNumber,
                            _posToBid,
                            {
                                value: val.toString(),
                            }
                        )
                    ).to.be.revertedWith(
                        "Must send more than last bid by minBidIncrementPercentage amount"
                    )
                    // await expectRevert(this.token.balanceOf(ZERO_ADDRESS), 'ERC721: address zero is not a valid owner');
                    if (_verbose) console.log(`val ok1 : ${val}`)
                    continue
                }
                // console.log(`the address ${acclist[i].address} bids ${val}`)
                _posToBid = await MAH.findPos(_auctionNumber, val)
                _signer = await ethers.getSigner(acclist[i].address)
                await MAH.connect(_signer).createBid(
                    _auctionNumber,
                    _posToBid,
                    {
                        value: val.toString(),
                    }
                )
                if (_verbose) console.log(`val ok2 : ${val}`)
            }
        })
    }
})

describe("testin multi Item Simultaneous auction bidding and Transfering", () => {
    let MAH, Mtoken, MAHfactory, MTokenFactory
    const _itemInAuction = 5
    let acclist
    beforeEach(async function () {
        MAHfactory = await ethers.getContractFactory("MultiAuctionHouse")
        MAH = await MAHfactory.deploy()
        // console.log(`this is the contract address ${MAH.address}`)
        // const acclist = await ethers.getSigners()
        MTokenFactory = await ethers.getContractFactory("MToken")

        Mtoken = await MTokenFactory.deploy()
        await Mtoken.transferOwnership(MAH.address)
        await MAH.initialize(Mtoken.address, _itemInAuction, 0, 0, 2, 300)
        acclist = await ethers.getSigners()
    })
    for (j = 0; j < 10; j++) {
        it("biding and get", async () => {
            // const _MtokenBalance = await Mtoken.balanceOf(MAH.address)
            // assert.equal(_MtokenBalance, _itemInAuction)
            let _posToBid
            let _signer
            let _bidable
            let _auctionNumber, val
            let _listOfBids = []
            let _len, _bidder, _bidValue, _currentPos
            let toeknList
            _auctionNumber = await MAH.getCurrentAuctionNumber()
            for (i = 0; i < 10; i++) {
                val = getRandomIntInclusive(1, 100)
                _signer = await ethers.getSigner(acclist[i].address)
                _bidable = await MAH.isBidable(_auctionNumber, val.toString())
                if (_verbose) console.log(`val : ${val}`)
                if (!_bidable) {
                    _posToBid = await MAH.findPos(_auctionNumber, val)
                    if (_verbose)
                        console.log(
                            `${val} is bidable? ${_bidable} at pos : ${_posToBid}`
                        )
                    await expect(
                        MAH.connect(_signer).createBid(
                            _auctionNumber,
                            _posToBid,
                            {
                                value: val.toString(),
                            }
                        )
                    ).to.be.revertedWith(
                        "Must send more than last bid by minBidIncrementPercentage amount"
                    )
                    // await expectRevert(this.token.balanceOf(ZERO_ADDRESS), 'ERC721: address zero is not a valid owner');
                    if (_verbose) console.log(`val ok1 : ${val}`)
                    continue
                }
                // console.log(`the address ${acclist[i].address} bids ${val}`)
                _posToBid = await MAH.findPos(_auctionNumber, val)
                _signer = await ethers.getSigner(acclist[i].address)
                await MAH.connect(_signer).createBid(
                    _auctionNumber,
                    _posToBid,
                    {
                        value: val.toString(),
                    }
                )
                if (_verbose) console.log(`val ok2 : ${val}`)
            }
            await MAH.finishIt(_auctionNumber)
            _len = await MAH.getLen(_auctionNumber)
            _currentPos = await MAH.getHead(_auctionNumber)
            for (i = 0; i < _len; i++) {
                _currentPos = await MAH.getNext(_auctionNumber, _currentPos)
                _bidder = await MAH.getBidder(_auctionNumber, _currentPos)
                _bidValue = await MAH.getData(_auctionNumber, _currentPos)
                _listOfBids.push({
                    pos: _currentPos,
                    bidder: _bidder,
                    bidValue: _bidValue,
                })
            }
            if (_verbose) console.log(_listOfBids)
            let _numBids = await MAH.numberOfItem(_auctionNumber)
            let _tokenList = [0, 1, 2, 3, 4] //[...Array(5).keys()]
            if (_verbose) console.log(`is ${_tokenList}`)
            let _index, _rndTokneId, _owner, tokenNumber
            // for (i = 0; i < _tokenList.length; i++) {}

            for (i = 0; i < _numBids; i++) {
                _bidder = _listOfBids[i].bidder
                _pos = _listOfBids[i].pos
                _bidValue = _listOfBids[i].bidvalue
                _signer = await ethers.getSigner(_bidder)
                _index = getRandomIntInclusive(0, _tokenList.length - 1)
                if (_verbose) console.log(`index ${_index}`)

                tokenNumber = _tokenList[_index]
                _tokenList.splice(_index, 1)
                if (_verbose) console.log(`${tokenNumber} `)
                await MAH.connect(_signer).getToken(
                    _auctionNumber,
                    tokenNumber,
                    _pos
                )
                let _MtokenBalance = await Mtoken.balanceOf(_bidder)
                expect(_MtokenBalance).to.equal(1)
                tokenOwner = await Mtoken.ownerOf(tokenNumber)
                // console.log(`ww ${tokenNumber}`)
                if (_verbose) console.log(`toeknList is ${_tokenList}`)
                expect(tokenOwner).to.equal(_signer.address)
            }
        })
    }
})

// describe("testin multi Item Simultaneous auction Token Transfer", () => {
//     let MAH, Mtoken, MAHfactory, MTokenFactory
//     const _itemInAuction = 5
//     let acclist
//     beforeEach(async function () {
//         MAHfactory = await ethers.getContractFactory("MultiAuctionHouse")
//         MAH = await MAHfactory.deploy()
//         // console.log(`this is the contract address ${MAH.address}`)
//         // const acclist = await ethers.getSigners()
//         MTokenFactory = await ethers.getContractFactory("MToken")

//         Mtoken = await MTokenFactory.deploy()
//         await Mtoken.transferOwnership(MAH.address)
//         await MAH.initialize(Mtoken.address, _itemInAuction, 0, 0, 2, 300)
//         acclist = await ethers.getSigners()
//         // console.log("wtf")
//     })
//     // for (j = 0; j < 5; j++) {
//     it("bid then get quest", async () => {
//         // const _MtokenBalance = await Mtoken.balanceOf(MAH.address)
//         // assert.equal(_MtokenBalance, _itemInAuction)
//         let _posToBid
//         let _signer
//         let _bidable, val
//         let _auctionNumber = await MAH.getCurrentAuctionNumber()
//         let _listOfBids = []
//         let _len, _bidder, _bidValue, _currentPos
//         let _pos, _lenBids, _MtokenBalance

//         for (i = 0; i < 10; i++) {
//             console.log(`auction number is ${_auctionNumber}`)
//             val = getRandomIntInclusive(1, 100)
//             _signer = await ethers.getSigner(acclist[i].address)
//             console.log("wtf1")
//             _bidable = await MAH.isBidable(_auctionNumber, val.toString())
//             console.log("wtf")
//             if (true) {
//                 console.log(`val : ${val}`)
//             }
//             if (!_bidable) {
//                 _posToBid = await MAH.findPos(_auctionNumber, val)
//                 if (true)
//                     console.log(
//                         `${val} is bidable? ${_bidable} at pos : ${_posToBid}`
//                     )
//                 await expect(
//                     MAH.connect(_signer).createBid(_auctionNumber, _posToBid, {
//                         value: val.toString(),
//                     })
//                 ).to.be.revertedWith(
//                     "Must send more than last bid by minBidIncrementPercentage amount"
//                 )
//                 // await expectRevert(this.token.balanceOf(ZERO_ADDRESS), 'ERC721: address zero is not a valid owner');
//                 if (true) console.log(`val ok1 : ${val}`)

//                 // continue
//             } else {
//                 // console.log(`the address ${acclist[i].address} bids ${val}`)
//                 _posToBid = await MAH.findPos(_auctionNumber, val)

//                 await MAH.connect(_signer).createBid(
//                     _auctionNumber,
//                     _posToBid,
//                     {
//                         value: val.toString(),
//                     }
//                 )
//                 if (true) console.log(`val ok2 : ${val}`)
//             }
//             //

//             _currentPos = await MAH.getHead(_auctionNumber)
//             // let _listOfBids = []
//             // let _len, _bidder, _bidValue
//             _len = await MAH.numberOfItem(_auctionNumber)
//             await MAH.finishIt(_auctionNumber)

//             for (i = 0; i < _len; i++) {
//                 _currentPos = await MAH.getNext(_auctionNumber, _currentPos)
//                 _bidder = await MAH.getBidder(_auctionNumber, _currentPos)
//                 _bidValue = await MAH.getData(_auctionNumber, _currentPos)
//                 _listOfBids.push({
//                     bidder: _bidder,
//                     bidvalue: _bidValue,
//                     pos: _currentPos,
//                 })
//             }
//             console.log(_listOfBids)
//             _lenBids = _listOfBids.length

//             for (i = 0; i < _lenBids; i++) {
//                 _bidder = _listOfBids[i].bidder
//                 _pos = _listOfBids[i].pos
//                 _bidValue = _listOfBids[i].bidvalue
//                 _signer = await ethers.getSigner(_bidder)
//                 await MAH.connect(_signer).getToken(
//                     _auctionNumber,
//                     i,
//                     _currentPos
//                 )
//                 _MtokenBalance = await Mtoken.balanceOf(_bidder)
//                 expect(_MtokenBalance).to.equal(1)
//             }
//         }
//     })
//     // }
// })

// describe("testin multi Item Simultaneous auction Token Transfer", () => {
//     let MAH, Mtoken, MAHfactory, MTokenFactory
//     const _itemInAuction = 7
//     let acclist
//     beforeEach(async function () {
//         MAHfactory = await ethers.getContractFactory("MultiAuctionHouse")
//         MAH = await MAHfactory.deploy()
//         // console.log(`this is the contract address ${MAH.address}`)
//         // const acclist = await ethers.getSigners()
//         MTokenFactory = await ethers.getContractFactory("MToken")

//         Mtoken = await MTokenFactory.deploy()
//         await Mtoken.transferOwnership(MAH.address)
//         await MAH.initialize(Mtoken.address, _itemInAuction, 0, 0, 2, 300)
//         acclist = await ethers.getSigners()
//     })
//     for (j = 0; j < 5; j++) {
//         it("bid then get with random number", async () => {
//             // const _MtokenBalance = await Mtoken.balanceOf(MAH.address)
//             // assert.equal(_MtokenBalance, _itemInAuction)
//             let _posToBid
//             let _signer
//             let _bidable
//             let _auctionNumber = await MAH.getCurrentAuctionNumber()

//             for (i = 0; i < 10; i++) {
//                 let val = getRandomIntInclusive(1, 100)
//                 _signer = await ethers.getSigner(acclist[i].address)
//                 _bidable = await MAH.isBidable(_auctionNumber, val.toString())
//                 if (_verbose) console.log(`val : ${val}`)
//                 if (!_bidable) {
//                     _posToBid = await MAH.findPos(_auctionNumber, val)
//                     if (_verbose)
//                         console.log(
//                             `${val} is bidable? ${_bidable} at pos : ${_posToBid}`
//                         )
//                     await expect(
//                         MAH.connect(_signer).createBid(
//                             _auctionNumber,
//                             _posToBid,
//                             {
//                                 value: val.toString(),
//                             }
//                         )
//                     ).to.be.revertedWith(
//                         "Must send more than last bid by minBidIncrementPercentage amount"
//                     )
//                     // await expectRevert(this.token.balanceOf(ZERO_ADDRESS), 'ERC721: address zero is not a valid owner');
//                     if (_verbose) console.log(`val ok1 : ${val}`)
//                     continue
//                 }

//                 // console.log(`the address ${acclist[i].address} bids ${val}`)
//                 _posToBid = await MAH.findPos(_auctionNumber, val)
//                 _signer = await ethers.getSigner(acclist[i].address)
//                 await MAH.connect(_signer).createBid(
//                     _auctionNumber,
//                     _posToBid,
//                     {
//                         value: val.toString(),
//                     }
//                 )
//                 //
//                 if (_verbose) console.log(`val ok2 : ${val}`)
//                 let _listOfBids = []
//                 let _len, _bidder, _bidValue, _currentNode
//                 describe("getting token with a random number", async () => {
//                     beforeEach(async () => {
//                         _currentNode = await MAH.getHead(_auctionNumber)
//                         // let _listOfBids = []
//                         // let _len, _bidder, _bidValue
//                         _len = await MAH.numberOfItem(_auctionNumber)
//                         await MAH.finishIt(_auctionNumber)
//                         for (i = 0; i < _len; i++) {
//                             _currentNode = await MAH.getNext(
//                                 _auctionNumber,
//                                 _currentPos
//                             )
//                             _bidder = await MAH.getBidder(
//                                 _auctionNumber,
//                                 _currentPos
//                             )
//                             _bidValue = await MAH.getData(
//                                 _auctionNumber,
//                                 _currentPos
//                             )
//                             _listOfBids.push({
//                                 bidder: _bidder,
//                                 bidvalue: _bidValue,
//                                 pos: _currentNode,
//                             })
//                         }
//                     })
//                 })
//                 it("getToken with random number", async () => {
//                     let _lenBids = _listOfBids.length
//                     let _bidder, _bidValue, _signer, _pos
//                     let toeknList = Array(5).keys()
//                     let tokenNumber
//                     let _index
//                     let tokenOwner
//                     for (i = 0; i < _lenBids; i++) {
//                         _bidder = _listOfBids[i].bidder
//                         _pos = _listOfBids[i].pos
//                         _bidValue = _listOfBids[i].bidvalue
//                         _signer = await ethers.getSigner(_bidder)
//                         _index = getRandomIntInclusive(0, toeknList.length)
//                         tokenNumber = toeknList[_index]
//                         toeknList.pop(_index)
//                         await MAH.connect(_signer).getToken(
//                             _auctionNumber,
//                             tokenNumber,
//                             _currentPos
//                         )
//                         let _MtokenBalance = await Mtoken.balanceOf(_bidder)
//                         expect(_MtokenBalance).to.equal(1)
//                         tokenOwner = await Mtoken.owenerOf(1)
//                         console.log(`ww ${tokenNumber}`)
//                         expect(tokenOwner).to.equal(_signer.address)
//                     }
//                 })
//             }
//         })
//     }
// })

function getRandomIntInclusive(min, max) {
    min = Math.ceil(min)
    max = Math.floor(max)
    return Math.floor(Math.random() * (max - min + 1) + min) // The maximum is inclusive and the minimum is inclusive
}
