# Docker CI/CD演示场景

May 31, 2023

# 项目需求

**CloudZun:** 我想做一个最简单的基于docker 容器的CI/CD演示场景，以下是一些要求 
1.应用用最简单的html静态页面实现，代码存放在github上，同时包含dockerfile文件 
2.应用提交更新之后自动创建映像并且保存在docker hub里 
3.映像更新好之后，让运行这个映像的容器宿主机更新对应的应用程序容器 
请帮忙看一下这个要求是否能实现，如果可以实现大致的实现步骤先告诉我，不用提供具体的实现细节，实现细节我们放在随后的步骤里进行讨论，谢谢！

**ChatGPT:** 这个要求是完全可以实现的。基于你的需求，这是一个基本的基于Docker容器的CI/CD(持续集成/持续部署)的场景，可以使用GitHub Actions和Docker Hub完成。

以下是一个大致的实现步骤：

1. **创建静态HTML应用并将其存储在GitHub上**：您可以创建一个简单的HTML文件并使用Dockerfile创建一个服务该HTML文件的服务器。Dockerfile可能非常简单，只需要基于一个已有的web服务器镜像，例如nginx，然后将你的HTML文件复制到镜像中的适当位置。
2. **设置GitHub Actions**：GitHub Actions 是 GitHub 提供的一个自动化工具，可以在你的仓库上执行各种自动化操作。你可以创建一个workflow，当你向主分支提交更改时，它将自动构建一个Docker映像并将其推送到Docker Hub。
3. **在Docker Hub上设置一个自动构建**：你的GitHub Actions workflow将使用你的Docker Hub的凭证将新构建的映像推送到你的Docker Hub仓库。
4. **设置Docker容器的自动更新**：在容器宿主机上，你可以使用像Watchtower这样的工具来监控Docker Hub上映像的更新，并在有新版本可用时自动拉取新版本并重启你的应用容器。

这些步骤将实现你所描述的CI/CD场景：当你更新你的应用并将更改提交到GitHub时，一个新的Docker映像将自动构建并推送到Docker Hub，然后你的Docker容器将自动拉取新映像并更新你的应用。

具体的实现细节可能会根据你的具体环境和需求有所不同，但这个大致的过程应该是适用的。希望这个答案对你有帮助！如果你有任何具体的问题，欢迎随时提问。







# 创建项目文件

好的，那么接下来，我们逐步完成这个项目，我们先做第一步 创建静态HTML应用并将其存储在GitHub上，不过和你预先设计的不同，我们使用httpd这个映像作为静态HTML的基准映像，接下来请给我HTML文件和dockerfile文件的范例，谢谢！

**ChatGPT:** 非常好，下面是HTML文件和Dockerfile的示例。

**1. HTML文件**

这是一个最简单的HTML文件，名字可以为`index.html`：

```html
<!DOCTYPE html>
<html>
<head>
    <title>我的静态页面</title>
</head>
<body>
    <h1>欢迎来到我的静态页面！</h1>
    <p>这是一个简单的HTML静态页面。</p>
</body>
</html>
```

**2. Dockerfile**

以下是一个简单的Dockerfile，它基于httpd映像，并将你的静态页面复制到镜像中：

```dockerfile
# 使用httpd作为基准映像
FROM httpd:2.4

# 将你的静态页面复制到镜像中
COPY ./index.html /usr/local/apache2/htdocs/

# 当容器启动时运行httpd
CMD ["httpd-foreground"]
```

请将这个Dockerfile和你的HTML文件放在你的GitHub仓库中的同一个目录下，然后提交这些文件到GitHub。这就完成了第一步。







# 设置GitHub Actions自动构建并推送镜像到Docker Hub

**CloudZun：**好的，第一步已经完成，我的项目库的路径在https://github.com/cloudzun/cicdlab/，请继续提供第二步设置GitHub Actions的操作步骤，谢谢！

**ChatGPT:** 非常好，下面是如何设置GitHub Actions来自动构建并推送Docker镜像到Docker Hub的步骤：

1. 在你的项目根目录下创建一个新的文件夹名为`.github/workflows`。
2. 在`.github/workflows`文件夹中创建一个新的YAML文件，如`dockerimage.yml`。
3. 在`dockerimage.yml`中添加以下内容：

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main # Change this to your default branch if it's not 'main'

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v2
      
    - name: Login to DockerHub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKER_HUB_USERNAME }}
        password: ${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}

    - name: Build and push Docker image
      uses: docker/build-push-action@v2
      with:
        context: .
        push: true
        tags: docker.io/${{ secrets.DOCKER_HUB_USERNAME }}/cicdlab:latest
```

此工作流程文件将在每次将更改推送到主分支时触发，并且会构建并将Docker映像推送到Docker Hub。

1. 在你的GitHub项目的`Settings`页面中，进入`Secrets`菜单，并添加你的Docker Hub用户名和访问令牌。这些密钥将在你的工作流中用于登录到Docker Hub。添加以下两个secret：
   - `DOCKER_HUB_USERNAME` - 你的Docker Hub用户名
   - `DOCKER_HUB_ACCESS_TOKEN` - 你的Docker Hub访问令牌

现在每次向`main`分支（或者你在`dockerimage.yml`中设置的默认分支）提交更改时，GitHub Actions都将自动构建一个新的Docker映像并将其推送到你的Docker Hub仓库。



---



**CloudZun：**DOCKER_HUB_ACCESS_TOKEN这个需要在docker hub里创建吗，请给出具体步骤，谢谢！

**ChatGPT:** 是的，你需要在Docker Hub上创建一个访问令牌。以下是如何在Docker Hub创建访问令牌的步骤：

1. 登录你的Docker Hub账户。
2. 点击你的用户名，然后在下拉菜单中选择"Account Settings"。
3. 在左侧的菜单中，选择"Security"。
4. 在"New Access Token"下，给你的新令牌输入一个名字，然后点击"Create"。名字可以是任何你喜欢的名字，但最好选择一个能帮助你记住该令牌用途的名字。
5. 你的新令牌将显示在下一屏幕上。确保你复制了这个令牌，因为你将无法再次看到它。

然后你可以将这个访问令牌复制到你的GitHub仓库的Secrets设置中（作为`DOCKER_HUB_ACCESS_TOKEN`）。



---



**CloudZun：**好了，请告诉我第三步 在Docker Hub上设置一个自动构建 的操作吧

**ChatGPT:** 实际上，根据前面我们在GitHub Actions中设置的操作，每次你提交代码，都会触发GitHub Actions自动构建Docker镜像并将它推送到Docker Hub。因此，你并不需要在Docker Hub上设置自动构建。

GitHub Actions已经接管了这部分工作。每次你推送更改到GitHub，它都会自动构建新的Docker镜像，并使用你在GitHub Secrets中设置的Docker Hub凭据将镜像推送到Docker Hub。

所以，在这个设置中，Docker Hub主要作为存储和分发Docker镜像的平台，而真正的自动构建工作是由GitHub Actions完成的。

请确认你的GitHub Actions工作流正常工作，即当你向GitHub仓库提交更改时，可以在GitHub Actions的日志中看到构建和推送Docker镜像的过程，并且可以在Docker Hub的仓库中看到新的镜像。



---



**CloudZun：**执行的时候报错了，错误在login to dockerhub，具体错误是 Error: Username and password required

**ChatGPT:** 这个错误提示表示在尝试登录Docker Hub时，GitHub Actions无法获取到你的Docker Hub用户名和密码。这可能是因为在GitHub仓库的Secrets设置中，`DOCKER_HUB_USERNAME`和`DOCKER_HUB_ACCESS_TOKEN`这两个值没有被正确地设置。

你需要在你的GitHub项目的`Settings`页面中，进入`Secrets`菜单，并添加你的Docker Hub用户名和访问令牌。这些密钥将在你的工作流中用于登录到Docker Hub。添加以下两个secret：

- `DOCKER_HUB_USERNAME` - 你的Docker Hub用户名
- `DOCKER_HUB_ACCESS_TOKEN` - 你的Docker Hub访问令牌

这些值必须与你在Docker Hub上的实际用户名和访问令牌相匹配。请确保正确输入这两个值，并确保`dockerimage.yml`文件中引用这两个secrets的方式是正确的。







# 设置Docker容器的自动更新

**CloudZun：**上述问题按照您的提示我已经解决了，而且我已经在某个宿主机上使用`docker run -d -p 80:80 chengzh/cicdlab` 运行了这个容器化服务，目前效果达到预期，请告诉我第四部的具体步骤，谢谢！

**ChatGPT:** 非常好，很高兴听到前面的步骤顺利完成。下面是使用Watchtower自动更新你的Docker应用容器的步骤：

1. 首先，你需要在你的Docker主机上安装和运行Watchtower。Watchtower是一个Docker容器，可以监视你的其他容器，并在Docker Hub上发现新的映像时自动更新它们。

你可以使用以下命令启动Watchtower：

```bash
docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --interval 30
```

在这个命令中，`--interval 30`参数使Watchtower每30秒检查一次更新。

1. 现在，你需要确保你的应用容器启动时使用了正确的Docker Hub镜像标签。Watchtower通过比较Docker Hub上的新镜像和本地镜像的标签来判断是否有新版本可用。

如果你在运行你的应用容器时使用了类似`chengzh/cicdlab:latest`的标签，那么只要在Docker Hub上有新的`latest`标签出现，Watchtower就会发现并拉取新的映像，然后重启你的应用容器。

你已经运行了这个命令 `docker run -d -p 80:80 chengzh/cicdlab`，它默认使用了`latest`标签，因此Watchtower应该可以正常工作。

现在，只要你在GitHub上提交新的更改，GitHub Actions就会自动构建新的Docker镜像并推送到Docker Hub，然后Watchtower将自动拉取新的映像并重启你的应用容器。
