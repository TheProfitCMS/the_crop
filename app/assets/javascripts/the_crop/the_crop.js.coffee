@TheCrop = do ->
  # HELPERS
  dec: (val) -> parseInt val, 10
  json_to_str: (json = {}) -> JSON.stringify(json)
  by_id: (id) -> document.getElementById(id)

  # INIT
  init: ->
    @params = {}
    do @init_open_btn
    do @init_close_btn
    do @init_submit
    do @init_ajaxian_callback

  init_open_btn: ->
    $('.js_the_crop').on 'click', (e) =>
      link    = $ e.target
      params  = link.data()
      @params = params if params

      @show_canvas()
      @create(params)
      false

  init_close_btn: ->
    $('.js_the_crop_close').on 'click', =>
      do @destroy
      do @hide_canvas
      false

  init_submit: ->
    $('.js_the_crop_submit').on 'click', =>
      form = $('.js_crop_form')

      x = $('#crop_x', form).val()
      y = $('#crop_y', form).val()
      w = $('#crop_w', form).val()
      h = $('#crop_h', form).val()

      if x is '0' && y is '0' && w is '0' && h is '0'
        alert 'Please, select crop area'
      else
        $('.js_crop_form').submit()

      false

  init_ajaxian_callback: ->
    $('.js_crop_form').on 'ajax:success', (e, data, status, xhr) =>
      callback = null
      fn_chain = @params.callbackHandler.split '.'

      for fn in fn_chain
        callback = if callback then callback[fn] else window[fn]

      callback(data, @params) if callback

  init_crop_form: ->
    $('.js_crop_form').attr('action', @params.url)

  init_jcrop: (context) =>
    $('#js_jcrop_target').Jcrop
      onChange: context.buildPreview
      onSelect: context.buildPreview
      setSelect: [0,0,100,100]
      aspectRatio: context.get_aspect_ration()
    , ->
      context.api = @

  # GETTERS
  get_aspect_ration: ->
    prev = $('.js_preview_image')
    @dec(prev.css('width')) / @dec(prev.css('height'))

  # SETTERS
  set_crop_form_params: (c) ->
    form     = $('.js_crop_form')
    orig_img = $('#js_jcrop_target')

    # Set img size for calc scale value
    img_w = $('#crop_img_w', form)
    img_w.val TheCrop.dec orig_img.css('width')

    # Set crop params
    x = $('#crop_x', form)
    y = $('#crop_y', form)
    w = $('#crop_w', form)
    h = $('#crop_h', form)

    x.val(c.x); y.val(c.y)
    w.val(c.w); h.val(c.h)

  set_preview_defaults: ->
    $('.js_preview_image').css
      width: 300
      height: 300

  set_preview_dimensions: ->
    if prev_opt = @params?.preview
      if prev_opt?.width && prev_opt?.height
        $('.js_preview_image').css
          width: prev_opt.width
          height: prev_opt.height

  set_holder_defaults: ->
    if holder_opt = @params?.holder
      if holder_opt?.width
        $('.js_source_image').css
          width: holder_opt.width

  set_holder_image_same_dimentions: ->
    holder  = $('.js_source_image')
    src_img = $('#js_jcrop_target')

    width = @dec holder.css 'width'
    src_img.css { width: width }

    src_img_height = @dec src_img.css 'height'
    holder.css { height: src_img_height }

  set_original_image_size_info: ->
    w = @by_id('js_jcrop_target').width
    h = @by_id('js_jcrop_target').height

    $('.js_the_crop_src_size').html """
      #{ w }x#{ h } (px)
    """

  set_croped_image_size_info: (w, h) ->
    $('.js_the_crop_cropped_size').html """
      #{ w }x#{ h } (px)
    """

  set_final_size_info: ->
    if @params.finalSize
      item = $('.js_the_crop_final_size')
      item.html "#{ @params.finalSize } (px)"
      item.parent().show()

  set_canvas_dimensions: ->
    do @set_preview_defaults
    do @set_preview_dimensions

    do @set_holder_defaults
    do @set_holder_image_same_dimentions

  # FUNCTIONS
  create: ->
    do @set_original_image_size_info
    do @set_canvas_dimensions
    do @set_final_size_info
    do @init_crop_form
    @init_jcrop @

  destroy: ->
    @api.destroy()

  buildPreview: (coords) ->
    preview_holder  = $('.js_preview_image')
    original_img    = $('#js_jcrop_target')

    preview_view_w = TheCrop.dec preview_holder.css('width')
    preview_view_h = TheCrop.dec preview_holder.css('height')

    original_view_w = TheCrop.dec original_img.css('width')
    original_view_h = TheCrop.dec original_img.css('height')

    orig_image_w = TheCrop.by_id('js_jcrop_target').width

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

    $('#js_preview').css
      width:  "#{ Math.round(rx * original_view_w) }px"
      height: "#{ Math.round(ry * original_view_h) }px"

      marginLeft: "-#{ Math.round(rx * coords.x) }px"
      marginTop:  "-#{ Math.round(ry * coords.y) }px"

  # OTHERS
  show_canvas: ->
    canvas = $('.js_the_crop_canvas')

    canvas.css
      width:  $(document).width()
      height: $(document).height()

    canvas.fadeIn()

  hide_canvas: ->
    $('.js_the_crop_canvas').fadeOut()
