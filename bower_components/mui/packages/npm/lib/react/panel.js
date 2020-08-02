var babelHelpers = require('./babel-helpers.js');
/**
 * MUI React layout module
 * @module react/layout
 */
'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;

var _react = babelHelpers.interopRequireDefault(require("react"));

function _createSuper(Derived) { return function () { var Super = babelHelpers.getPrototypeOf(Derived), result; if (_isNativeReflectConstruct()) { var NewTarget = babelHelpers.getPrototypeOf(this).constructor; result = Reflect.construct(Super, arguments, NewTarget); } else { result = Super.apply(this, arguments); } return babelHelpers.possibleConstructorReturn(this, result); }; }

function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }

/**
 * Panel constructor
 * @class
 */
var Panel = /*#__PURE__*/function (_React$Component) {
  babelHelpers.inherits(Panel, _React$Component);

  var _super = _createSuper(Panel);

  function Panel() {
    babelHelpers.classCallCheck(this, Panel);
    return _super.apply(this, arguments);
  }

  babelHelpers.createClass(Panel, [{
    key: "render",
    value: function render() {
      var _this$props = this.props,
          children = _this$props.children,
          className = _this$props.className,
          reactProps = babelHelpers.objectWithoutProperties(_this$props, ["children", "className"]);
      return /*#__PURE__*/_react.default.createElement("div", babelHelpers.extends({}, reactProps, {
        className: 'mui-panel ' + className
      }), children);
    }
  }]);
  return Panel;
}(_react.default.Component);
/** Define module API */


babelHelpers.defineProperty(Panel, "defaultProps", {
  className: ''
});
var _default = Panel;
exports.default = _default;
module.exports = exports.default;