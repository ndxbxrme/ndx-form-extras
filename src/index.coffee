'use strict'
module = null
try
  module = angular.module 'ndx'
catch e
  module = angular.module 'ndx', []
module
.run ($rootScope, $window, $state, $timeout, ndxCheck) ->
  root = Object.getPrototypeOf $rootScope
  root.redirect = 'back'
  root.saveFn = (cb) ->
    cb? true
  root.cancelFn = (cb) ->
    cb? true
  root.save = (name) ->
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
          adding = true
          keys = []
          for key of @
            keys.push key
          for key of @
            if key.indexOf('$') is 0
              continue
            if Object.prototype.toString.call(@[key]) is '[object Object]'
              if @[key].item
                if @[key].item._id
                  adding = false
                @[key].locked = false
                @[key].save()
          @editing = false
          ndxCheck.setPristine @
          message = ''
          if @messageFn
            message = @messageFn "#{name}-alerts-#{if adding then 'added' else 'updated'}"
          else
            message = if adding then 'Added' else 'Updated'
          if @alertFn
            @alertFn message          
          if @redirect
            if @redirect is 'back'
              if $rootScope.auth
                $rootScope.auth.goToLast @defaultLast
              else
                $window.history.go -1
            else
              $state.go @redirect
    else
      if $
        $timeout ->
          offset = $('.error:visible').parent('.form-item').offset()
          if offset
            $('html, body').animate
              scrollTop: offset.top - 72
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
              $rootScope.auth.goToLast @defaultLast
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