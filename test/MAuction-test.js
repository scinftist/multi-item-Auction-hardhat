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
    for (j = 0; j < 5; j++) {
        it("biding", async () => {
            // const _MtokenBalance = await Mtoken.balanceOf(MAH.address)
            // assert.equal(_MtokenBalance, _itemInAuction)
            let _posToBid
            let _signer
            let _bidable
            for (i = 0; i < 10; i++) {
                let val = getRandomIntInclusive(1, 100)
                _signer = await ethers.getSigner(acclist[i].address)
                _bidable = await MAH.isBidable(val.toString())
                if (_verbose) console.log(`val : ${val}`)
                if (!_bidable) {
                    _posToBid = await MAH.findPos(val)
                    if (_verbose)
                        console.log(
                            `${val} is bidable? ${_bidable} at pos : ${_posToBid}`
                        )
                    await expect(
                        MAH.connect(_signer).createBid(_posToBid, {
                            value: val.toString(),
                        })
                    ).to.be.revertedWith(
                        "Must send more than last bid by minBidIncrementPercentage amount"
                    )
                    // await expectRevert(this.token.balanceOf(ZERO_ADDRESS), 'ERC721: address zero is not a valid owner');
                    if (_verbose) console.log(`val ok1 : ${val}`)
                    continue
                }
                // console.log(`the address ${acclist[i].address} bids ${val}`)
                _posToBid = await MAH.findPos(val)
                _signer = await ethers.getSigner(acclist[i].address)
                await MAH.connect(_signer).createBid(_posToBid, {
                    value: val.toString(),
                })
                if (_verbose) console.log(`val ok2 : ${val}`)
            }
        })
    }
})

describe("testin multi Item Simultaneous auction Token Transfer", () => {
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
    for (j = 0; j < 5; j++) {
        it("bid then get", async () => {
            // const _MtokenBalance = await Mtoken.balanceOf(MAH.address)
            // assert.equal(_MtokenBalance, _itemInAuction)
            let _posToBid
            let _signer
            let _bidable
            for (i = 0; i < 10; i++) {
                let val = getRandomIntInclusive(1, 100)
                _signer = await ethers.getSigner(acclist[i].address)
                _bidable = await MAH.isBidable(val.toString())
                if (_verbose) console.log(`val : ${val}`)
                if (!_bidable) {
                    _posToBid = await MAH.findPos(val)
                    if (_verbose)
                        console.log(
                            `${val} is bidable? ${_bidable} at pos : ${_posToBid}`
                        )
                    await expect(
                        MAH.connect(_signer).createBid(_posToBid, {
                            value: val.toString(),
                        })
                    ).to.be.revertedWith(
                        "Must send more than last bid by minBidIncrementPercentage amount"
                    )
                    // await expectRevert(this.token.balanceOf(ZERO_ADDRESS), 'ERC721: address zero is not a valid owner');
                    if (_verbose) console.log(`val ok1 : ${val}`)
                    continue
                }
                // console.log(`the address ${acclist[i].address} bids ${val}`)
                _posToBid = await MAH.findPos(val)
                _signer = await ethers.getSigner(acclist[i].address)
                await MAH.connect(_signer).createBid(_posToBid, {
                    value: val.toString(),
                })
                if (_verbose) console.log(`val ok2 : ${val}`)
                let _listOfBids = []
                let _len, _bidder, _bidValue, _currentNode
                describe("getting", async () => {
                    beforeEach(async () => {
                        _currentNode = await MAH.getHead()
                        // let _listOfBids = []
                        // let _len, _bidder, _bidValue
                        _len = await MAH.numberOfItem()
                        await MAH.finishIt()
                        for (i = 0; i < _len; i++) {
                            _currentNode = await MAH.getNext(_currentPos)
                            _bidder = await MAH.getBidder(_currentPos)
                            _bidValue = await MAH.getData(_currentPos)
                            _listOfBids.push({
                                bidder: _bidder,
                                bidvalue: _bidValue,
                                pos: _currentNode,
                            })
                        }
                    })
                })
                it("getToken", async () => {
                    let _lenBids = _listOfBids.length
                    let _bidder, _bidValue, _signer, _pos
                    for (i = 0; i < _len; i++) {
                        _bidder = _listOfBids[i].bidder
                        _pos = _listOfBids[i].pos
                        _bidValue = _listOfBids[i].bidvalue
                        _singer = await ethers.getSigner(_bidder)
                        await MAH.connect(_singer).getToken(i, _currentPos)
                        let _MtokenBalance = await Mtoken.balanceOf(_bidder)
                        expect(_MtokenBalance).to.equal(1)
                    }
                })
            }
        })
    }
})

function getRandomIntInclusive(min, max) {
    min = Math.ceil(min)
    max = Math.floor(max)
    return Math.floor(Math.random() * (max - min + 1) + min) // The maximum is inclusive and the minimum is inclusive
}
