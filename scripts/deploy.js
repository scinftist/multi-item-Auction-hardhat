// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, waffle } = require("hardhat")

async function main() {
    const MAHfactory = await ethers.getContractFactory("MultiAuctionHouse")
    const MAH = await MAHfactory.deploy()
    console.log(`this is the contract address ${MAH.address}`)
    const acclist = await ethers.getSigners() //aquire wallets
    // for (i = 0; i < 5; i++) {
    //     console.log(`the address ${acclist[i].address}`)
    // }
    const MTokenFactory = await ethers.getContractFactory("MToken")

    const Mtoken = await MTokenFactory.deploy()

    const MtokenOwner = await Mtoken.owner()

    console.log(MtokenOwner)
    await Mtoken.transferOwnership(MAH.address)

    const MTokenAddress = await Mtoken.address
    let initTx = await MAH.initialize(MTokenAddress, 5, 0, 0, 0, 100)
    let initRec = await initTx.wait(1)
    console.log(`this the initialize gasUsed ${initRec.gasUsed}`)
    // const provider = waffle.provider
    const _MtokenBalance = await Mtoken.balanceOf(MAH.address)
    console.log(`number of token Owned by ${_MtokenBalance}`)
    const _ownertoken = await Mtoken.ownerOf(`1`)
    console.log(`owner of token 1 is ${_ownertoken}`)
    // await MAH.create()
    for (i = 0; i < 10; i++) {
        let val = i * 1000
        console.log(`the address ${acclist[i].address} bids ${val}`)
        let _posToBid = await MAH.findPos(val)
        let tx = await MAH.connect(acclist[i]).createBid(_posToBid, {
            value: val.toString(),
        })

        let = rec = await tx.wait(1)
        console.log(
            ` gas used ${
                rec.gasUsed
            } and current balance ${await ethers.provider.getBalance(
                MAH.address
            )}`
        )
    }

    const _len = await MAH.getLen()
    let _currentPos = await MAH.getHead()
    for (i = 0; i < _len; i++) {
        _currentPos = await MAH.getNext(_currentPos)
        let _bidder = await MAH.getBidder(_currentPos)
        let _bidValue = await MAH.getData(_currentPos)

        console.log(`the bidder is ${_bidder} at ${_bidValue} value`)
    }
    const finishTx = await MAH.finishIt()
    const finsihRec = await finishTx.wait(1)
    console.log(`finish gasUsed  ${finsihRec.gasUsed}`)
    _currentPos = await MAH.getHead()
    for (i = 0; i < _len; i++) {
        _currentPos = await MAH.getNext(_currentPos)
        let _bidder = await MAH.getBidder(_currentPos)
        let _bidValue = await MAH.getData(_currentPos)
        let _singer = await ethers.getSigner(_bidder)
        // console.log(`the bidder is ${_bidder} at ${_bidValue} value`)
        await MAH.connect(_singer).getToken(i, _currentPos)
        let _MtokenBalance = await Mtoken.balanceOf(_bidder)
        console.log(`number of token Owned by ${_bidder} is ${_MtokenBalance}`)
    }
}
function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
