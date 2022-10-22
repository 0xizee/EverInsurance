module.exports = async function mockDeploy({getNamedAccounts , deployments}){
    const {deploy , log} = deployments;
    const {deployer} = await getNamedAccounts();

    const MockAggregator = await deploy('MockV3Aggregator',{
        from : deployer,
        log : true,
        args : [100, 100000]
    })
}

module.exports.tags = ['all','Mock'];