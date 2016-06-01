# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
log = (x...) -> try console.log x...

_ = require('wegweg')({
  globals: no
  shelljs: no
})

module.exports = class Tokens

  constructor: (@opt={}) ->
    @opt.redis ?= _.redis 'localhost'
    @redis = @opt.redis
    @opt.redis_key ?= 'issuetokens'

  issue: (opt,cb) ->
    if !cb and _.type(opt) is 'function'
      cb = opt
      opt = {}

    opt.expires_secs ?= _.seconds('5 minutes')

    token = _.uuid() + _.time()
    token = _.random_string(128)

    key = @opt.redis_key + ':' + token
    await @redis.setex key, opt.expires_secs, token, defer e
    if e then return cb e

    return cb null, token

  redeem: (token,cb) ->
    key = @opt.redis_key + ':' + token

    await @redis.get key, defer e,r
    if e then return cb e

    if !r then return cb new Error 'Token does not exist'

    await @redis.del key, defer e
    if e then return cb e

    return cb null, yes

##
if !module.parent
  log /TESTING/

  t = new Tokens
  log /ISSUE/
  await t.issue {expires_secs:60}, defer e,token
  log e
  log token
  log /REDEEM/
  await t.redeem token, defer e,r
  log e
  log r
  log /REDEEM/
  await t.redeem token, defer e,r
  log e
  log r

