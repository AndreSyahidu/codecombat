module.exports.formToObject = ($el, options) ->
  options = _.extend({ trim: true, ignoreEmptyString: true }, options)
  obj = {}

  inputs = $('input, textarea, select', $el)
  for input in inputs
    input = $(input)
    continue unless name = input.attr('name')
    if input.attr('type') is 'checkbox'
      obj[name] ?= []
      if input.is(':checked')
        obj[name].push(input.val())
    else if input.attr('type') is 'radio'
      continue unless input.is('checked')
      obj[name] = input.val()
    else
      value = input.val() or ''
      value = _.string.trim(value) if options.trim
      if value or (not options.ignoreEmptyString)
        obj[name] = value
  obj
  
module.exports.objectToForm = ($el, obj, options={}) ->
  options = _.extend({ overwriteExisting: false })
  inputs = $('input, textarea, select', $el)
  for input in inputs
    input = $(input)
    continue unless name = input.attr('name')
    continue unless obj[name]?
    if input.attr('type') is 'checkbox'
      value = input.val()
      if _.contains(obj[name], value)
        input.attr('checked', true)
    else if input.attr('type') is 'radio'
      value = input.val()
      if obj[name] is value
        input.attr('checked', true)
    else
      if options.overwriteExisting or (not input.val())
        input.val(obj[name])

module.exports.applyErrorsToForm = (el, errors, warning=false) ->
  errors = [errors] if not $.isArray(errors)
  missingErrors = []
  for error in errors
    if error.code is tv4.errorCodes.OBJECT_REQUIRED
      prop = _.last(_.string.words(error.message)) # hack
      message = 'Required field'
    
    else if error.dataPath
      prop = error.dataPath[1..]
      message = error.message

    else
      message = "#{error.property} #{error.message}."
      message = message[0].toUpperCase() + message[1..]
      message = error.message if error.formatted
      prop = error.property

    missingErrors.push error unless setErrorToProperty el, prop, message, warning
  missingErrors

# Returns the jQuery form group element in case of success, otherwise undefined
module.exports.setErrorToField = setErrorToField = (el, message, warning=false) ->
  formGroup = el.closest('.form-group')
  unless formGroup.length
    return console.error el, " did not contain a form group, so couldn't show message:", message

  kind = if warning then 'warning' else 'error'
  afterEl = $(formGroup.find('.help-block, .form-control, input, select, textarea')[0])
  formGroup.addClass "has-#{kind}"
  helpBlock = $("<span class='help-block #{kind}-help-block'>#{message}</span>")
  if afterEl.length
    afterEl.before helpBlock
  else
    formGroup.append helpBlock

module.exports.setErrorToProperty = setErrorToProperty = (el, property, message, warning=false) ->
  input = $("[name='#{property}']", el)
  unless input.length
    return console.error "#{property} not found in", el, "so couldn't show message:", message

  setErrorToField input, message, warning
  
module.exports.scrollToFirstError = ($el=$('body')) ->
  $first = $el.find('.has-error, .alert-danger, .error-help-block, .has-warning, .alert-warning, .warning-help-block').first()
  $('body').animate({ scrollTop: $first.offset().top - 20 }, 300)

module.exports.clearFormAlerts = (el) ->
  $('.has-error', el).removeClass('has-error')
  $('.has-warning', el).removeClass('has-warning')
  $('.alert.alert-danger', el).remove()
  $('.alert.alert-warning', el).remove()
  el.find('.help-block.error-help-block').remove()
  el.find('.help-block.warning-help-block').remove()
