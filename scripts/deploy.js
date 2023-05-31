// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat")

async function main() {
    const MAHfactory = await ethers.getContractFactory("MAuctionHouse")
    const MAH = await MAHfactory.deploy()
    console.log(`this is the contract address ${MAH.address}`)
    const acclist = await ethers.getSigners() //aquire wallets
    // for (i = 0; i < 5; i++) {
    //     console.log(`the address ${acclist[i].address}`)
    // }

    await MAH.create()
    for (i = 0; i < 10; i++) {
        console.log(`the address ${acclist[i].address}`)
        let val = i * 1000
        const _posToBid = await MAH.findPos(val)
        await MAH.connect(acclist[i]).createBid(_posToBid, {
            value: val.toString(),
        })
    }

    const _len = await MAH.getLen()
    let _currentPos = await MAH.getHead()
    for (i = 0; i < _len; i++) {
        _currentPos = await MAH.getNext(_currentPos)
        let _bidder = await MAH.getBidder(_currentPos)
        let _bidValue = await MAH.getData(_currentPos)

        console.log(`the bidder is ${_bidder} at ${_bidValue} value`)
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
