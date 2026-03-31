"use strict"; function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; } function _optionalChain(ops) { let lastAccessLHS = undefined; let value = ops[0]; let i = 1; while (i < ops.length) { const op = ops[i]; const fn = ops[i + 1]; i += 2; if ((op === 'optionalAccess' || op === 'optionalCall') && value == null) { return undefined; } if (op === 'access' || op === 'optionalAccess') { lastAccessLHS = value; value = fn(value); } else if (op === 'call' || op === 'optionalCall') { value = fn((...args) => value.call(lastAccessLHS, ...args)); lastAccessLHS = undefined; } } return value; }require('dotenv/config');
require('./clients/db');
var _express = require('express'); var _express2 = _interopRequireDefault(_express);
var _boom = require('boom'); var _boom2 = _interopRequireDefault(_boom);
var _cors = require('cors'); var _cors2 = _interopRequireDefault(_cors);
var _ratelimiter = require('./rate-limiter'); var _ratelimiter2 = _interopRequireDefault(_ratelimiter);
var _routes = require('./routes'); var _routes2 = _interopRequireDefault(_routes);

const app = _express2.default.call(void 0, );
const port = Number(process.env.PORT || 4000);
const corsOrigin = _optionalChain([process, 'access', _ => _.env, 'access', _2 => _2.CORS_ORIGIN, 'optionalAccess', _3 => _3.split, 'call', _4 => _4(','), 'access', _5 => _5.map, 'call', _6 => _6((origin) => origin.trim()), 'access', _7 => _7.filter, 'call', _8 => _8(Boolean)]);

app.use(
  _cors2.default.call(void 0, {
    origin: _optionalChain([corsOrigin, 'optionalAccess', _9 => _9.length]) ? corsOrigin : true,
  })
);
app.use(_ratelimiter2.default);
app.use(_express2.default.json());
app.use(_express2.default.urlencoded({ extended: true }));

app.use(_routes2.default);

app.use((req, res, next) => {
  return next(_boom2.default.notFound('This route does not exist.'));
});

app.use((err, req, res, next) => {
  console.log(err);

  if (err) {
    if (err.output) {
      return res.status(err.output.statusCode || 500).json(err.output.payload);
    }

    return res.status(500).json(err);
  }
});

app.listen(port, () => console.log(`Server is up on port ${port}!`));
