$(document).ajaxComplete (event, request) ->
  msg = request.getResponseHeader("X-Flash[Error]")
  $.jGrowl(msg, {theme: 'error', life: 5000}) if msg?
