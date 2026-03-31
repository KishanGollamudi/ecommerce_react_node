"use strict";Object.defineProperty(exports, "__esModule", {value: true}); function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; } function _optionalChain(ops) { let lastAccessLHS = undefined; let value = ops[0]; let i = 1; while (i < ops.length) { const op = ops[i]; const fn = ops[i + 1]; i += 2; if ((op === 'optionalAccess' || op === 'optionalCall') && value == null) { return undefined; } if (op === 'access' || op === 'optionalAccess') { lastAccessLHS = value; value = fn(value); } else if (op === 'call' || op === 'optionalCall') { value = fn((...args) => value.call(lastAccessLHS, ...args)); lastAccessLHS = undefined; } } return value; }var _jsonwebtoken = require('jsonwebtoken'); var _jsonwebtoken2 = _interopRequireDefault(_jsonwebtoken);
var _boom = require('boom'); var _boom2 = _interopRequireDefault(_boom);
var _user = require('../models/user'); var _user2 = _interopRequireDefault(_user);

const signAccessToken = (data) => {
	return new Promise((resolve, reject) => {
		const payload = {
			...data,
		};

		const options = {
			expiresIn: "10d",
			issuer: "ecommerce.app",
		};

		_jsonwebtoken2.default.sign(payload, process.env.JWT_SECRET, options, (err, token) => {
			if (err) {
				console.log(err);
				return reject(_boom2.default.internal());
			}

			resolve(token);
		});
	});
};

const verifyAccessToken = (req, res, next) => {
	const authorizationHeader = req.headers["authorization"];
	if (!authorizationHeader) {
		return next(_boom2.default.unauthorized());
	}

	const authorizationToken = authorizationHeader.startsWith("Bearer ")
		? authorizationHeader.split(" ")[1]
		: authorizationHeader;

	return _jsonwebtoken2.default.verify(authorizationToken, process.env.JWT_SECRET, (err, payload) => {
		if (err) {
			return next(
				_boom2.default.unauthorized(
					err.name === "JsonWebTokenError" ? "Unauthorized" : err.message
				)
			);
		}

		req.payload = payload;
		next();
	});
};

const signRefreshToken = (user_id) => {
	return new Promise((resolve, reject) => {
		const payload = {
			user_id,
		};
		const options = {
			expiresIn: "180d",
			issuer: "ecommerce.app",
		};

		_jsonwebtoken2.default.sign(payload, process.env.JWT_REFRESH_SECRET, options, (err, token) => {
			if (err) {
				console.log(err);
				return reject(_boom2.default.internal());
			}

			return _user2.default.findByIdAndUpdate(
				user_id,
				{ refreshToken: token },
				{ new: true }
			)
				.then((user) => {
					if (!user) {
						return reject(_boom2.default.unauthorized());
					}

					return resolve(token);
				})
				.catch(() => reject(_boom2.default.internal()));
		});
	});
};

const verifyRefreshToken = async (refresh_token) => {
	return new Promise(async (resolve, reject) => {
		_jsonwebtoken2.default.verify(
			refresh_token,
			process.env.JWT_REFRESH_SECRET,
			async (err, payload) => {
				if (err) {
					return reject(_boom2.default.unauthorized());
				}

				const { user_id } = payload;
				const user = await _user2.default.findById(user_id).select("+refreshToken");

				if (!_optionalChain([user, 'optionalAccess', _ => _.refreshToken])) {
					return reject(_boom2.default.unauthorized());
				}

				if (refresh_token === user.refreshToken) {
					return resolve(user_id);
				}

				return reject(_boom2.default.unauthorized());
			}
		);
	});
};






exports.signAccessToken = signAccessToken; exports.verifyAccessToken = verifyAccessToken; exports.signRefreshToken = signRefreshToken; exports.verifyRefreshToken = verifyRefreshToken;
