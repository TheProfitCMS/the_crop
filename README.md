# TheCrop

```scss
  //= require the_crop/the_crop
  //= require jcrop/jquery.Jcrop
```

```coffee
//= require the_crop/the_crop
//= require jcrop/jquery.Jcrop
//= require ./MyCropCallbacks

$ ->
  do TheCrop.init
```

```slim
doctype html
html(lang="ru")
  head
    meta(charset="utf-8")

    = csrf_meta_tags
    = stylesheet_link_tag    :application
    = javascript_include_tag :application

  body
    = yield
    = yield :the_crop
```


```ruby
Rails.application.routes.draw do
  resources :posts
    member do
      patch  :image_crop_base
      patch  :image_crop_preview
      patch  :image_rotate
      delete :image_delete
    end
  end
```

```ruby
class PostsController < ApplicationController
  before_action :set_post
  before_action :authenticate_user!

  def image_crop_base
    path = @post.image_crop_base(params)
    render json: { ids: { image_base_pic: path } }
  end

  def image_crop_preview
    path = @post.image_crop_preview(params)
    render json: { ids: { image_preview_pic: path } }
  end

  def image_rotate
    @post.image_rotate
    redirect_to :back
  end

  def image_delete
    @post.image_destroy!
    redirect_to :back
  end
end
```

```slim
= render partial: 'the_crop/canvas', locals: { image: post.image.url(:original) }

- if post.image?
  :ruby
    crop_data_base = {
      role: :js_the_crop,

      url:    url_for([:image_crop_base, post]),
      source: post.image.url(:original),

      holder:  { width: 500 },
      preview: { width: 270, height: 210 },

      final_size: "270x210",
      callback_handler: "TheCrop.post_image_crop"
    }

    crop_data_preview = {
      role: :js_the_crop,

      url:    url_for([:image_crop_preview, post]),
      source: post.image.url(:original),

      holder:  { width: 500 },
      preview: { width: 100, height: 100 },

      final_size: "100x100",
      callback_handler: "TheCrop.post_image_crop"
    }

  = link_to "Crop 270x210", "#", data: crop_data_base
  = link_to "Crop 100x100", "#", data: crop_data_preview

```
