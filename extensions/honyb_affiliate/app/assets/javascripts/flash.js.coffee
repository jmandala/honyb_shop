$(document).ajaxComplete (event, request) ->
  msg = request.getResponseHeader("X-Flash[Error]")
  $.jGrowl(msg, {theme: 'error'}) if msg?
