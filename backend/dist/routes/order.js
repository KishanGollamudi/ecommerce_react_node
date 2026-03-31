"use strict";Object.defineProperty(exports, "__esModule", {value: true}); function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }var _express = require('express'); var _express2 = _interopRequireDefault(_express);
const router = _express2.default.Router();

var _order = require('../controllers/order'); var _order2 = _interopRequireDefault(_order);
var _grantAccess = require('../middlewares/grantAccess'); var _grantAccess2 = _interopRequireDefault(_grantAccess);

router.post('/', _grantAccess2.default.call(void 0, 'createOwn', 'order'), _order2.default.Create);
router.get('/', _grantAccess2.default.call(void 0, 'readAny', 'order'), _order2.default.List);
router.get('/my-orders', _grantAccess2.default.call(void 0, 'readOwn', 'order'), _order2.default.GetMyOrders);

exports. default = router;
