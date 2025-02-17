const Witnet = require("witnet-requests");
const { keccak256 } = require("js-sha3"); // Ensure you have this package installed

// Build the request using the witnet-requests API:
const request = new Witnet.Request()
  .addSource("https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd")
  // Use an aggregator with a reducer and an empty filters array:
  .setAggregator({ reducer: Witnet.Types.REDUCERS.averageMean, filters: [] })
  // Use a tally with a reducer and an empty filters array:
  .setTally({ reducer: Witnet.Types.REDUCERS.averageMedian, filters: [] })
  .setQuorum(10)
  // Set collateral to at least 1 WIT (1,000,000,000 nanoWits)
  .setCollateral(1000000000)
  .setFees(1000000)
  .schedule(Date.now())
  .setTimestamp(Math.floor(Date.now() / 1000))
  .asJson();

// Generate the hash from the JSON representation:
const requestJson = JSON.stringify(request);
const requestHash = "0x" + keccak256(requestJson);
console.log("Witnet Request Hash:", requestHash);
    