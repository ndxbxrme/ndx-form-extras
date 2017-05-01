(function() {
  'use strict';
  var e, error, module;

  module = null;

  try {
    module = angular.module('ndx');
  } catch (error) {
    e = error;
    module = angular.module('ndx', []);
  }

  module.run(function($rootScope, $window, ndxCheck) {
    var root;
    root = Object.getPrototypeOf($rootScope);
    root.saveFn = function(cb) {
      return typeof cb === "function" ? cb(true) : void 0;
    };
    root.cancelFn = function(cb) {
      return typeof cb === "function" ? cb(true) : void 0;
    };
    root.save = function() {
      var checkScope, isValid;
      isValid = true;
      checkScope = function(scope) {
        var key, results;
        results = [];
        for (key in scope) {
          if (scope.hasOwnProperty(key)) {
            if (Object.prototype.toString.call(scope[key]) === '[object Object]') {
              if (scope[key].$$controls) {
                results.push(isValid = isValid && scope[key].$valid);
              } else {
                results.push(void 0);
              }
            } else {
              results.push(void 0);
            }
          } else {
            results.push(void 0);
          }
        }
        return results;
      };
      checkScope(this);
      if (this.forms) {
        checkScope(this.forms);
      }
      this.submitted = true;
      if (isValid) {
        return this.saveFn((function(_this) {
          return function(result) {
            var key;
            if (result) {
              for (key in _this) {
                if (Object.prototype.toString.call(_this[key]) === '[object Object]') {
                  if (_this[key].item) {
                    console.log('i want to save', _this[key]);
                    _this[key].locked = false;
                    _this[key].save();
                  }
                }
              }
              _this.editing = false;
              ndxCheck.setPristine(_this);
              if (_this.redirect) {
                if (_this.redirect === 'back') {
                  return $window.history.go(-1);
                }
              }
            }
          };
        })(this));
      }
    };
    root.cancel = function() {
      return this.cancelFn((function(_this) {
        return function(result) {
          var key;
          if (result) {
            _this.submitted = false;
            _this.editing = false;
            for (key in _this) {
              if (_this.hasOwnProperty(key)) {
                if (Object.prototype.toString.call(_this[key]) === '[object Object]') {
                  if (_this[key].item) {
                    _this[key].locked = false;
                    _this[key].refreshFn();
                  }
                }
              }
            }
            ndxCheck.setPristine(_this);
            if (_this.redirect) {
              if (_this.redirect === 'back') {
                return $window.history.go(-1);
              }
            }
          }
        };
      })(this));
    };
    return root.edit = function() {
      var key, results;
      this.submitted = false;
      this.editing = true;
      results = [];
      for (key in this) {
        if (this.hasOwnProperty(key)) {
          if (Object.prototype.toString.call(this[key]) === '[object Object]') {
            if (this[key].item) {
              results.push(this[key].locked = true);
            } else {
              results.push(void 0);
            }
          } else {
            results.push(void 0);
          }
        } else {
          results.push(void 0);
        }
      }
      return results;
    };
  });

}).call(this);

//# sourceMappingURL=index.js.map
