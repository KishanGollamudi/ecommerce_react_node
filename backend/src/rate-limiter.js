import RateLimit from 'express-rate-limit';
import Boom from 'boom';

const limiter = new RateLimit({
  windowMs: 30 * 1000,
  max: 1000,
  handler: (req, res, next) => {
    next(Boom.tooManyRequests());
  },
});

export default limiter;
