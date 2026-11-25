FROM nginx:alpine

# 应用本体直接进镜像，不依赖运行期 git
COPY . /usr/share/nginx/html/

# 清掉不该进镜像的东西（.dockerignore 已先过滤一遍，这里兜底）
RUN rm -rf /usr/share/nginx/html/.git \
           /usr/share/nginx/html/.github

EXPOSE 80
