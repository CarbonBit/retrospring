($ document).on 'submit', 'form.edit_doorkeeper_application', (ev) ->
  # ev.preventDefault()
  scopes = []
  ($ this).find("[name=\"scopes\"]").each ->
    if this.checked
      scopes.push this.value
  ($ "[name=\"doorkeeper_application[scopes]\"]").val(scopes.join " ")


readImage = (file, callback) ->
  fr = new FileReader()
  fr.addEventListener "load", (e) ->
    callback e.target.result
  fr.readAsBinaryString file

freeURL = () ->

if window.URL? or window.webkitURL?
  readImage = (file, callback) ->
    callback (window.URL || window.webkitURL).createObjectURL file
  freeURL = (url) ->
    URL.revokeObjectURL url

($ document).on 'change', 'input#doorkeeper_application_icon[type=file]', ->
  input = this

  ($ '#app-icon-crop-controls').slideUp 400, ->
    if input.files and input.files[0]
      readImage input.files[0], (src) ->
        cropper = ($ '#app-icon-cropper')
        preview = ($ '#app-icon-preview')

        updateVars = (data, action) ->
          ($ '#crop_x').val Math.floor(data.x / data.scale)
          ($ '#crop_y').val Math.floor(data.y / data.scale)
          ($ '#crop_w').val Math.floor(data.w / data.scale)
          ($ '#crop_h').val Math.floor(data.h / data.scale)

        cropper.on 'load', ->
          if ({}.toString).call(src) == "[object URL]"
            freeURL src

          side = if cropper[0].naturalWidth > cropper[0].naturalHeight
            cropper[0].naturalHeight
          else
            cropper[0].naturalWidth

          cropper.guillotine
            width: side
            height: side
            onChange: updateVars

          updateVars cropper.guillotine('getData'), 'drag' # just because

          unless ($ '#app-icon-crop-controls')[0].dataset.bound?
            ($ '#cropper-zoom-out').click -> cropper.guillotine 'zoomOut'
            ($ '#cropper-zoom-in').click -> cropper.guillotine 'zoomIn'
            ($ '#app-icon-crop-controls')[0].dataset.bound = true
          ($ '#app-icon-crop-controls').slideDown()

        cropper.attr 'src', src