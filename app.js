const express = require('express');
const path = require('path');

const app = express();
const port = Number(process.env.PORT) || 3000;

app.use(express.static(path.join(__dirname, 'public')));

app.get('/health', (req, res) => {
  res.status(200).send('ok');
});

app.listen(port, () => {
  console.log(`Server listening on http://localhost:${port}`);
});
