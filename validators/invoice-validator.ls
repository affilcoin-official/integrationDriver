require! {
    \joi : Joi
}
module.exports =
    body:
      amount            : Joi.string!.min(3).max(15).required!
      amount-currency   : Joi.string!.min(3).max(5).required!
      callback-url      : Joi.string!.min(3).max(100).required!
      invoice-currency  : Joi.string!.min(3).max(5).required!