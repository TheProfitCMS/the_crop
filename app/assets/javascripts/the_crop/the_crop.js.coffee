@TheCrop = do ->
  # HELPERS
  dec: (val) -> parseInt val, 10

  # INIT
  init: ->
    @params = {}

    do @init_open_btn
    do @init_close_btn

    do @init_submit
    do @init_ajaxian_callback

  define_controls: ->
    @doc    = $ document
    @canvas = $ "@the_crop_canvas_#{ @params.cropId }"
    @close  = @canvas.find('@the_crop_close')

    @src_size     = @canvas.find('@src_size')
    @cropped_size = @canvas.find('@cropped_size')
    @final_size   = @canvas.find('@final_size')

    @src_image_holder = @canvas.find('@src_image_holder')
    @src_image        = @canvas.find('@src_image')

    @preview_image_holder = @canvas.find('@preview_image_holder')
    @preview_image        = @canvas.find('@preview_image')

    @crop_form   = @canvas.find('@crop_form')
    @crop_submit = @canvas.find('@crop_submit')

    @crop_img_w = @canvas.find('@crop_img_w')

    @crop_x = @canvas.find('@crop_x')
    @crop_y = @canvas.find('@crop_y')
    @crop_w = @canvas.find('@crop_w')
    @crop_h = @canvas.find('@crop_h')

  set_crop_form_params: (c) ->
    img_w = TheCrop.dec @src_image.css('width')

    @crop_img_w.val img_w

    @crop_x.val(c.x)
    @crop_y.val(c.y)

    @crop_w.val(c.w)
    @crop_h.val(c.h)

  init_submit: ->
    $(document).on 'click', '@crop_submit', =>
      form = TheCrop.crop_form

      x = TheCrop.crop_x.val()
      y = TheCrop.crop_y.val()
      w = TheCrop.crop_w.val()
      h = TheCrop.crop_h.val()

      if x is '0' && y is '0' && w is '0' && h is '0'
        alert 'Please, select crop area'
      else
        form.submit()

  buildPreview: (coords) ->
    original_view_w = TheCrop.dec TheCrop.src_image.css('width')
    original_view_h = TheCrop.dec TheCrop.src_image.css('height')

    preview_view_w = TheCrop.dec TheCrop.preview_image_holder.css('width')
    preview_view_h = TheCrop.dec TheCrop.preview_image_holder.css('height')

    orig_image_w = TheCrop.src_image[0].naturalWidth

    # Calculate scale
    scale = original_view_w / orig_image_w
    sw = TheCrop.dec coords.w / scale
    sh = TheCrop.dec coords.h / scale

    # Set scaled sizes
    TheCrop.set_croped_image_size_info(sw, sh)

    # When crop-area not selected
    if sw is 0 && sh is 0
      TheCrop.set_crop_form_params({ x: 0, y: 0, w: 0, h: 0 })
    else
      TheCrop.set_crop_form_params(coords)

    # Calculate values for preview
    rx = preview_view_w / coords.w
    ry = preview_view_h / coords.h

    TheCrop.preview_image.css
      width:  "#{ Math.round(rx * original_view_w) }px"
      height: "#{ Math.round(ry * original_view_h) }px"

      marginLeft: "-#{ Math.round(rx * coords.x) }px"
      marginTop:  "-#{ Math.round(ry * coords.y) }px"

  init_jcrop: =>
    TheCrop.src_image.Jcrop
      onChange: TheCrop.buildPreview
      onSelect: TheCrop.buildPreview
      setSelect: [0,0,100,100]
      aspectRatio: TheCrop.get_aspect_ration()
    , ->
      TheCrop.api = @

  init_open_btn: ->
    $(document).on 'click', '@the_crop_open', (e) =>
      link    = $ e.target
      params  = link.data()
      @params = params if params

      do @define_controls
      do @show_canvas
      do @create

  init_close_btn: ->
    $(document).keyup (e) =>
      if e.keyCode is $.ui.keyCode.ESCAPE
        do @destroy
        do @hide_canvas
        window.location.hash = @close.attr('href')

    $(document).on 'click', '@the_crop_close', =>
      do @destroy
      do @hide_canvas

  init_ajaxian_callback: ->
    $(document).on 'ajax:success', '@crop_form', (e, data, status, xhr) =>
      callback = null
      fn_chain = @params.callbackHandler.split '.'

      for fn in fn_chain
        callback = if callback then callback[fn] else window[fn]

      callback(data, @params) if callback

  init_crop_form: ->
    @crop_form.attr('action', @params.url)

  # GETTERS

  get_aspect_ration: ->
    preview = TheCrop.preview_image
    @dec(preview.css('width')) / @dec(preview.css('height'))

  # SETTERS
  set_preview_dimensions: ->
    @preview_image.css
      width:  300
      height: 300

    if prev_opt = @params?.preview
      if prev_opt?.width && prev_opt?.height
        @preview_image_holder.css
          width:  prev_opt.width
          height: prev_opt.height

        @preview_image.css
          width:  prev_opt.width
          height: prev_opt.height

  set_src_dimentions: ->
    @src_image_holder.css
      width:  @src_image[0].naturalWidth
      height: @src_image[0].naturalHeight

    @src_image.css
      width:  @src_image[0].naturalWidth
      height: @src_image[0].naturalHeight

  set_final_size_info: ->
    if @params.finalSize
      @final_size.html "#{ @params.finalSize } (px)"
      @final_size.parent().show()

  set_original_image_size_info: ->
    w = @src_image[0].naturalWidth
    h = @src_image[0].naturalHeight

    @src_size.html """
      #{ w }x#{ h } (px)
    """

  set_croped_image_size_info: (w, h) ->
    @cropped_size.html """
      #{ w }x#{ h } (px)
    """

  # CREATE/DESTROY FUNCTIONS

  create: ->
    do @set_preview_dimensions
    do @set_original_image_size_info

    do @set_src_dimentions
    do @set_final_size_info

    do @init_crop_form
    do @init_jcrop

  destroy: ->
    @api.destroy()

  # OTHERS
  show_canvas: ->
    @canvas.css
      width:  @doc.width()
      height: @doc.height()

    @canvas.fadeIn()

  hide_canvas: ->
    @canvas.fadeOut()
