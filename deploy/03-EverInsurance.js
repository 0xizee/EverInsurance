
module.exports = async function({getNamedAccounts , deployments}){
    const {deploy , log} = deployments;
    const {deployer} = await getNamedAccounts();

    const MockAggregator = await ethers.getContract('MockV3Aggregator' , deployer);
    
    const EverInsurance = await deploy('EverInsurance',{
        from : deployer,
        log : true,
        args : [MockAggregator.address],
        // waitConfirmations:2
    })
    log("Contract Deployed");
}

module.exports.tags = ['all','EverInsurance'];