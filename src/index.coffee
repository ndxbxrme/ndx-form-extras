'use strict'
module = null
try
  module = angular.module 'ndx'
catch e
  module = angular.module 'ndx', []
module
.run ($rootScope, $window, $state, ndxCheck) ->
  root = Object.getPrototypeOf $rootScope
  root.saveFn = (cb) ->
    cb? true
  root.cancelFn = (cb) ->
    cb? true
  root.save = ->
    isValid = true
    checkScope = (scope) ->
      for key of scope
        if scope.hasOwnProperty(key)
          if Object.prototype.toString.call(scope[key]) is '[object Object]'
            if scope[key].$$controls
              isValid = isValid and scope[key].$valid
    checkScope @
    if @.forms
      checkScope @.forms
    @submitted = true
    if isValid
      @saveFn (result) =>
        if result
          for key of @
            if Object.prototype.toString.call(@[key]) is '[object Object]'
              if @[key].item
                @[key].locked = false
                @[key].save()
          @editing = false
          ndxCheck.setPristine @
          if @redirect
            if @redirect is 'back'
              if $rootScope.auth
                $rootScope.auth.goToLast()
              else
                $window.history.go -1
            else
              $state.go @redirect
  root.cancel = ->
    @cancelFn (result) =>
      if result
        @submitted = false
        @editing = false
        for key of @
          if @.hasOwnProperty(key)
            if Object.prototype.toString.call(@[key]) is '[object Object]'
              if @[key].item
                @[key].locked = false
                @[key].refreshFn()
        ndxCheck.setPristine @
        if @redirect
          if @redirect is 'back'
            if $rootScope.auth
              $rootScope.auth.goToLast()
            else
              $window.history.go -1
          else
            $state.go @redirect
  root.edit = ->
    @submitted = false
    @editing = true
    for key of @
      if @.hasOwnProperty(key)
        if Object.prototype.toString.call(@[key]) is '[object Object]'
          if @[key].item
            @[key].locked = true