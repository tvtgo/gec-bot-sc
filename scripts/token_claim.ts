import bn from 'bignumber.js'
import * as hre from 'hardhat'
import * as fs from 'fs'
import { Signer, BigNumber } from 'ethers'
// const ethers = hre.ethers
import { Contract, ContractFactory, constants } from 'ethers'
import { network, ethers } from 'hardhat'

type ContractJson = { abi: any; bytecode: string }
const artifacts: { [name: string]: ContractJson } = {
  CLAIM: require('../artifacts/contracts/TokenClaim.sol/TokenClaim.json'),
}


async function main() {
  const [owner]: Signer[] | any = await ethers.getSigners()
  const networkName = network.name
  console.log('owner', owner.address)


  const CLAIM = new ContractFactory(
      artifacts.CLAIM.abi,
      artifacts.CLAIM.bytecode,
      owner
  )

  const _claimToken = '0xE8385CECb013561b69bEb63FF59f4d10734881f3';
  const _maxClaim = 0;
  const _signer = '0xA6F60197a624FBB8d8F1eFFE26fC100aF9C96faF';

  const claim: any = await CLAIM.deploy(_claimToken, _maxClaim, _signer)
  // await join.deployed();

  console.log('claim', claim.address)




  // await join.method.initialize()

  const contracts = {
    CLAIM: claim.address,
  }

  fs.writeFileSync(`./deployments/claim_token.json`, JSON.stringify(contracts))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
