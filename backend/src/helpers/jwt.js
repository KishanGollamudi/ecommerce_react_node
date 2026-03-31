import JWT from "jsonwebtoken";
import Boom from "boom";
import User from "../models/user";

const signAccessToken = (data) => {
	return new Promise((resolve, reject) => {
		const payload = {
			...data,
		};

		const options = {
			expiresIn: "10d",
			issuer: "ecommerce.app",
		};

		JWT.sign(payload, process.env.JWT_SECRET, options, (err, token) => {
			if (err) {
				console.log(err);
				return reject(Boom.internal());
			}

			resolve(token);
		});
	});
};

const verifyAccessToken = (req, res, next) => {
	const authorizationHeader = req.headers["authorization"];
	if (!authorizationHeader) {
		return next(Boom.unauthorized());
	}

	const authorizationToken = authorizationHeader.startsWith("Bearer ")
		? authorizationHeader.split(" ")[1]
		: authorizationHeader;

	return JWT.verify(authorizationToken, process.env.JWT_SECRET, (err, payload) => {
		if (err) {
			return next(
				Boom.unauthorized(
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

		JWT.sign(payload, process.env.JWT_REFRESH_SECRET, options, (err, token) => {
			if (err) {
				console.log(err);
				return reject(Boom.internal());
			}

			return User.findByIdAndUpdate(
				user_id,
				{ refreshToken: token },
				{ new: true }
			)
				.then((user) => {
					if (!user) {
						return reject(Boom.unauthorized());
					}

					return resolve(token);
				})
				.catch(() => reject(Boom.internal()));
		});
	});
};

const verifyRefreshToken = async (refresh_token) => {
	return new Promise(async (resolve, reject) => {
		JWT.verify(
			refresh_token,
			process.env.JWT_REFRESH_SECRET,
			async (err, payload) => {
				if (err) {
					return reject(Boom.unauthorized());
				}

				const { user_id } = payload;
				const user = await User.findById(user_id).select("+refreshToken");

				if (!user?.refreshToken) {
					return reject(Boom.unauthorized());
				}

				if (refresh_token === user.refreshToken) {
					return resolve(user_id);
				}

				return reject(Boom.unauthorized());
			}
		);
	});
};

export {
	signAccessToken,
	verifyAccessToken,
	signRefreshToken,
	verifyRefreshToken,
};
