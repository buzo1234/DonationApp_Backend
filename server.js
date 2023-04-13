const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
const contract = require('@truffle/contract');
const DonationContractJSON = require('./build/contracts/DonationContract.json');

const provider = new HDWalletProvider({
  mnemonic: {
    phrase: 'evil antenna child noble raven rigid since loud garden minimum ice debris'
  },
  providerOrUrl: 'http://127.0.0.1:7545'
});

const app = express();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

const port = process.env.PORT || 3001;

const web3 = new Web3(provider);
const donationContract = contract(DonationContractJSON);
donationContract.setProvider(web3.currentProvider);

let donationInstance;

const ngoAddress = '0xcA6eD644Bf536d44a35C7D81f8EaC0BF48623f71';

donationContract.deployed().then(function(instance) {
  donationInstance = instance;
});

app.use(express.static(path.join(__dirname, 'public')));

app.post('/donate', async (req, res) => {
  const { amount, purpose } = req.body;
  const accounts = await web3.eth.getAccounts();
  const donor = accounts[0];

  try {
    const result = await donationInstance.donate(purpose, { from: donor, value: web3.utils.toWei(amount, 'ether') });
    console.log(result);
    res.send(result);
  } catch (error) {
    console.log(error);
    res.status(500).send(error);
  }
});

app.get('/donations', async (req, res) => {
  try {
    const result = await donationInstance.getDonations({ from: ngoAddress });
    console.log(result);
    res.send(result);
  } catch (error) {
    console.log(error);
    res.status(500).send(error);
  }
});

app.get('/proposal/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await donationInstance.getProposal(id, { from: ngoAddress });
    console.log(result);
    res.send(result);
  } catch (error) {
    console.log(error);
    res.status(500).send(error);
  }
});

app.post('/proposal/approve', async (req, res) => {
  const { id } = req.body;
  try {
    const result = await donationInstance.approveProposal(id, { from: ngoAddress });
    console.log(result);
    res.send(result);
  } catch (error) {
    console.log(error);
    res.status(500).send(error);
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
