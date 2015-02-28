# 实验楼 － sinatra-blog-api 项目课文档

## 一、实验说明

### 1. 环境登录

无需密码自动登录，系统用户名shiyanlou，密码shiyanlou

### 2. 环境介绍

本实验环境采用带桌面的Ubuntu Linux环境，实验中会用到桌面上的程序：

1. LX终端（LXTerminal）: Linux命令行终端，打开后会进入Bash环境，可以使用Linux命令

2. Firefox：浏览器，可以用在需要前端界面的课程里，只需要打开环境里写的HTML/JS页面即可

3. GVim：非常好用的编辑器，最简单的用法可以参考课程[Vim编辑器](http://www.shiyanlou.com/courses/2)

### 3. 环境使用

使用GVim编辑器输入实验所需的代码及文件，使用LX终端（LXTerminal）运行所需命令进行操作。

完成实验后可以点击桌面上方的“实验截图”保存并分享实验结果到微博，向好友展示自己的学习进度。实验楼提供后台系统截图，可以真实有效证明您已经完成了实验。

实验记录页面可以在“我的主页”中查看，其中含有每次实验的截图及笔记，以及每次实验的有效学习时间（指的是在实验桌面内操作的时间，如果没有操作，系统会记录为发呆时间）。这些都是您学习的真实性证明。

本课程中的所有源码可以通过以下方式下载:

```
https://github.com/pobing/sinatra-blog-api.git
```
大家有学习过程中有任何问题，或有任何纰漏欢迎通过下面的邮箱地址咨询和反馈:

```
cn.jdongATgmail.com
```


## 二、项目介绍

现在大的应用程序分为前后端，前端有 web 端、移动端等。 为了满足不同的前端和后端通信，后端得提供一套标准的API方便与前端通信。

而 [RESTful API](http://en.wikipedia.org/wiki/Representational_state_transfer)是目前比较成熟的一套互联网应用程序的API设计理论。

本项目基于[Ruby](https://www.ruby-lang.org/en/) 的 [sinatra](http://www.sinatrarb.com/intro.html) 框架实现一个简单的 Blog Restful API 应用，提供基本的增删改查接口。

## 三、项目实战

### 0. 先安装的基本库, 打开 Xfce 终端输入如下命令：

```
sudo apt-get install ruby-dev
sudo apt-get install libsqlite3-dev
sudo gem install bundler
```

### 1. 创建项目目录,并创建项目库配置文件，打开 Xfce 终端输入如下命令：

```
mkdir sinatra-blog-api
cd sinatra-blog-api


cat > Gemfile
source 'https://ruby.taobao.org/'
gem 'rake'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-activerecord'
gem 'sqlite3'
[Ctrl-D]

```
安装gem 包，执行下面命令

```
bundle install
```
根据网络安装时长会有不同，完成后终端如下显示：
当终端 显示 `Bundle complete!`字样时说明安装成功


### 2. 创建数据模型

创建数据库配置文件：

```
mkdir config && cd config

cat > database.yml
development:
  adapter: sqlite3
  database: blog_development

[Ctrl-D]
```

为了执行rake 任务，我们先要创建 Rakefile 文件，并添加如下代码

```
cat > Rakefile
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
[Ctrl-D]

```

创建文章（posts）数据表，结构如下：

```
posts # 文章表

id: int # 文章唯一标识，主键
title: string #文章标题
body: text #文章内容
created_at: datetime #文章创建时间
updated_at: datetime #文章结束时间
```


生成数据迁移文件

```
bundle exec rake db:create_migration NAME=create_posts
```

项目根目录下会生成 db/migrate/yyyymmddhhmmss_create_posts.rb

用 vim 编辑器打开改文件，添加如下内容保存

```
class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end

```

然后执行迁移： 

```
bundle exec rake db:migrate
```


### 3. 接口描述

本项目是实现一个 Blog 的 API，我们需要实现以下接口：
```
GET /posts #列出所有文章
POST /posts #新建一篇文章
GET /posts/:id #获取某个指定的文章
PUT /posts/:id #更新某个指定文章（需提供该文章全部信息，不提供的则被更新为空）
PATCH /posts/:id #更新某个指定文章的信息（提供该文章部分信息，只更新提供的信息）
DELETE /posts/:id #删除某篇文章
```

本接口中会用到一些简单的 HTTP 状态码，


```
200 OK: 服务器成功返回用户请求的数据
201 CREATED : 用户新建数据成功
404 NOT FOUND: 用户发出的请求针对的是不存在的记录
422 Unprocesable entity: 发生一个验证错误
500 INTERNAL SERVER ERROR: 服务器发生错误
```
有兴趣的同学可以 [到此](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) 查看更多的状态码信息


### 4. 创建 Post model class 文件

项目根目录下执行

```
mkdir models

cat > models/post.rb

class Post < ActiveRecord::Base
end

[Ctrl-D]
```

### 5. 接口编码实现

首先创建项目主文件：

```
touch app.rb
```

至此我们的目录结构应该是这样： 

```
├── app.rb
├── config
│   └── database.yml
├── db
│   ├── migrate
│   │   └── 20150225142442_create_posts.rb
│   └── schema.rb
├── Gemfile
├── Gemfile.lock
├── models
│   └── post.rb
└── Rakefile
```

Rakefile 引用 app.rb 文件, 编辑后的 Rakefile 文件如下：

```
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require './app.rb'
```


接口实现，粘贴以下代码到 app.rb 文件中：

```
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
```

### 6. 运行项目

完成以上步骤后,我们就可以运行项目了，终端执行：

```
bundle exec ruby app.rb 
```
服务成功启动后，终端会如下显示了：

```
== Sinatra/1.4.5 has taken the stage on 4567 for development with backup from Thin
>> Thin web server (v1.3.1 codename Triple Espresso)
>> Maximum connections set to 1024
>> Listening on localhost:4567, CTRL+C to stop

```
然后打开firefox 浏览器，地址栏输入下面命令，便可看到项目正常运行： 

```
http://localhost:4567/posts

```

## 四、 项目测试
  
   我们用 [curl](http://curl.haxx.se/) 进行测试API，当然大家也可以在浏览器使用插件进行调试, 推荐 chrome 下的  [POSTMAN](https://chrome.google.com/webstore/detail/postman-rest-client/fhbjgbiflinjbdggehcddcbncdddomop)


首先我们请求文章列表接口：

```
curl -i -X GET http://localhost:4567/posts
```
调用成功后会如下显示：

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 2
X-Content-Type-Options: nosniff
Connection: keep-alive
Server: thin 1.3.1 codename Triple Espresso

[]%

```

我们看见除了返回 header 头 信息外，只返回了一个空数组，这是我们还没创建文章呢，

接下来我们创建一篇文章，调用创建文章接口，终端输入：


```
curl -X POST --data "title=My first post&body=This is post body."  http://localhost:4567/posts

```

成功时 http 状态码 201，并且返回创建好的数据，如下所示：

```
HTTP/1.1 201 Created
Content-Type: application/json
Content-Length: 144
X-Content-Type-Options: nosniff
Connection: keep-alive
Server: thin 1.3.1 codename Triple Espresso

{"id":1,"title":"My first post","body":"This is post body.","created_at":"2015-02-26T13:31:08.287Z","updated_at":"2015-02-26T13:31:08.287Z"}%

```

然后我们重新调用文章列表接口:

```
curl -i -X GET http://localhost:4567/posts
```
调用成功后会如下显示：

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 142
X-Content-Type-Options: nosniff
Connection: keep-alive
Server: thin 1.3.1 codename Triple Espresso

[{"id":1,"title":"My first post","body":"This is post body.","created_at":"2015-02-26T13:59:00.000Z","updated_at":"2015-02-26T13:59:00.000Z"}]%

```

返回了我们刚才创建的文章信息，我们现在只获取我们刚才创建的文章信息，终端输入：

```
curl -i -X GET http://localhost:4567/posts/1  # 1 为 文章id

```

请求成功后终端如下显示：

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 140
X-Content-Type-Options: nosniff
Connection: keep-alive
Server: thin 1.3.1 codename Triple Espresso

{"id":1,"title":"My first post","body":"This is post body.","created_at":"2015-02-26T13:59:00.000Z","updated_at":"2015-02-26T13:59:00.000Z"}%

```

如果我们请求一个不存在的文章，API 会怎么返回呢，我们尝试请求 id 为 2 的文章， 终端输入：

```
curl -i -X GET http://localhost:4567/posts/2

```

请求成功后终端如下显示：

```

HTTP/1.1 404
Content-Type: application/json
Content-Length: 23
X-Content-Type-Options: nosniff
Connection: keep-alive
Server: thin 1.3.1 codename Triple Espresso

{"message":"not found"}%
```

我们发现返回了 404 的 http 状态码，‘not found’ 的 message，因为我们确实 id 为2 的文章不存在。

接下来我们要更新文章信息，更新我们提供了 PUT 和 PATCH 这两个接口，两者的区别见接口描述部分

我们先测试 PUT 更新请求，终端输入：

```
curl -i -X PUT --data "title=Update title content&body=Update body content."  http://localhost:4567/posts/1
```

请求成功后终端如下显示：
```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 140
X-Content-Type-Options: nosniff
Connection: keep-alive
Server: thin 1.3.1 codename Triple Espresso

{"id":1,"title":"Update title content","body":"Update body content.","created_at":"2015-02-26T01:41:11.000Z","updated_at":"2015-02-26T13:33:11.058Z"}%
```


测试 PATCH 更新请求 ，终端输入：

```
curl -i -X PATCH --data "title=Only chage title"  http://localhost:4567/posts/1
```

请求成功后终端如下显示：
```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 140
X-Content-Type-Options: nosniff
Connection: keep-alive
Server: thin 1.3.1 codename Triple Espresso

{"id":1,"title":"Only chage title","body":"Update body content.","created_at":"2015-02-26T01:41:11.000Z","updated_at":"2015-02-26T13:34:15.462Z"}%
```

测试删除某篇文章的请求，终端输入：

```
curl -i -X  DELETE  http://localhost:4567/posts/1

```

请求成功后终端如下显示：

```
HTTP/1.1 204 No Content
X-Content-Type-Options: nosniff
Connection: close
Server: thin 1.3.1 codename Triple Espresso

```
我们看到终端返回了 204 的 http 状态码，body 没有返回任何内容，我们重新访问下文章列表测试下看有没有删除成功，终端输入：

```
curl -i -X GET http://localhost:4567/posts
```
调用成功后会如下显示：

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 2
X-Content-Type-Options: nosniff
Connection: keep-alive
Server: thin 1.3.1 codename Triple Espresso

[]%

```


看到 返回的 body 内容为空数组，说明我们删除成功！

## 五、结束语

到此我们的API接口全部测试完毕，本次的项目也就完成了，当然本项目只是一个简单的 Restful API 了。 当然一个设计优良的 Restful API 还有好多，有机会我们继续学习，希望这次的课程对大家有所帮助！


