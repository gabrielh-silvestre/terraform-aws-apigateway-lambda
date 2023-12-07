const axios = require('axios');

exports.handler = async function (event, context) {
  console.log('EVENT: \n' + JSON.stringify(event, null, 2));
  const res = await axios.get('https://pokeapi.co/api/v2/pokemon/ditto');

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Hello from Lambda!',
      data: res.data,
      event,
    }),
  };
};
