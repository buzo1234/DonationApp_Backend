const DonationContract = artifacts.require("DonationContract");

module.exports = function (deployer) {
  const param1 = "0x0Cb83dE30f35905491cA7985258D5623b0613c2b";
  const param2 = "0xf630f650308ec0207857d2F95c117f760DaC5087";

  deployer.deploy(DonationContract, param1, param2);
};
