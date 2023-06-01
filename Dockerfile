# 使用Alpine Linux作为基础映像
FROM alpine:latest

# 安装lighttpd
RUN apk add --no-cache lighttpd

# 将你的静态页面复制到镜像中
COPY ./index.html /var/www/localhost/htdocs/index.html

# 暴露80端口
EXPOSE 80

# 当容器启动时运行lighttpd
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

