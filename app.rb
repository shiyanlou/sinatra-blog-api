#encoding: utf-8

require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib'
require './models/post'

# 获取全部文章列表
get '/posts' do 
  posts = Post.all
  json posts
end

# 创建文章
post '/posts' do 
  post = Post.new(title: params[:title], body: params[:body])
  if post.save
    status 201
    json post
  else
    status 422
    json message: 'save fail'
  end
end

# 获取某篇文章
get '/posts/:id' do
  post = Post.find_by_id(params[:id])
  if post
    json post
  else
   status 404
   json message: 'not found'
  end
end

# 修改某篇文章，修改全部内容
put '/posts/:id' do
  post = Post.find_by_id(params[:id])
  if post.update_attributes(title: params[:title], body: params[:body])
    json post
  else
   status 422
   json message: 'update fail'
  end
end

# 修改某篇文章，修改部分内容
patch '/posts/:id' do
  post = Post.find_by_id(params[:id])
  unless post
   status 404
   return json message: 'not found'
  end
  post.title = params[:title] if params[:title]
  post.body = params[:body] if params[:body]
  if post.save
    json post
  else
   status 422
   json message: 'update fail'
  end
end

# 删除某篇文章
delete '/posts/:id' do
  post = Post.find_by_id(params[:id])
  if post && post.delete
    status 204
  else
   status 422
   json message: 'delete fail'
  end
end
