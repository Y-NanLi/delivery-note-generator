# 送货单生成器 (delivery-note-generator)

按「开异模板」送货单格式录入、打印送货单的本地小工具。单文件 HTML + 启动脚本，无需安装、无需联网，数据保存在本机浏览器中。

## 特点

- 版式适配：Epson LQ-300K+ / LQ-630KII 针式打印机 + 214.7×139.8mm 三联纸（默认版式，按实际纸张尺寸排），同时保留 A4 版式，可激光/喷墨打印或存 PDF。
- 单据管理：新建 / 保存 / 复制本单 / 打印；单据编号自动生成，前缀按单据类型区分（送货单 `XS`、样品单 `DB`、提前送货单 `TQ`），流水各算各的，形如 `XS-2026-11-25-00003`，也可手动填写。
- 备份迁移：支持「导出备份 / 导入备份」，换电脑时迁移单据记录。
- 导出 Excel：顶栏一键生成真正的 `.xlsx`（零依赖，不用装 Excel/WPS 插件）；列名、列序、隐藏列、列宽跟随「列设置」，数量是真数字、合计是真 `SUM` 公式，导出后可直接筛选求和。
- 货物明细记忆库（v1.23）：填过的「规格型号 + 存货名称 + 单位」自动记在本机，新单里再填同一规格就带出名称和单位（已填不覆盖）；工具栏显示「已存商品 N 条」，上限 1000 条；可单独导出/导入货物明细库，整份备份里也包含。
- 打印前实时预览，版式、页边距微调、三块字号均可调；可选「表格铺到纸底」，明细少时表格铺满纸面、合计与签字位固定在下方。

## 文件说明

| 文件 | 说明 |
| --- | --- |
| `送货单.html` | 主程序（双击可直接用浏览器打开） |
| `启动送货单.bat` | 推荐启动方式：以独立窗口打开，像一个小软件 |
| `start.ps1` | bat 调用的启动脚本（不要改名） |
| `使用说明.txt` | 完整使用说明（含打印机纸张设置步骤） |
| `样张/` | 各种版式 PDF 样张，用于对位置、看分页与合计 |
| `归档/` | 历史版本快照（按版本号 + 日期） |
| `index.html` | 首页，自动跳转到 `送货单.html`（仅 Docker/Web 托管时需要） |
| `docker-compose.yml` | NAS 部署用，镜像模式 / 源码同步模式（profile 切换） |
| `.env.example` | Compose 默认 profile 模板（复制成 `.env` 生效，`.env` 本身不入库） |
| `Dockerfile` | 构建镜像用（nginx + 网页本体） |
| `deploy/` | 可直接粘贴到飞牛 Docker 界面的两份 compose（镜像模式 / 源码模式） |
| `部署说明.md` | 飞牛 fnOS 图形界面部署步骤、模式切换、常见报错 |

## 快速开始

1. 双击 `启动送货单.bat`（Windows，依赖 PowerShell + Edge，无 Edge 时回退到默认浏览器）。
2. 首次使用请先给打印机建 241×140mm 纸张，步骤见 `使用说明.txt` 第三节。
3. 单据记录保存在本机浏览器里，换电脑请用软件内的「导出备份 / 导入备份」迁移，不要只拷 html 文件。

## Docker 部署（fnOS / 群晖等 NAS）

图形界面（飞牛 Docker → Compose → 新增项目）的完整步骤见 **[部署说明.md](部署说明.md)**，可直接粘贴的 compose 在 `deploy/` 下。

一个 `docker-compose.yml` 管两种模式，靠 profile 切换。两种模式都占 8088，同一时间只跑一种。

准备：

```bash
mkdir -p /vol1/1000/docker/delivery-note && cd /vol1/1000/docker/delivery-note
# 放入 docker-compose.yml 和 .env.example，然后生成实际配置
cp .env.example .env
```

### 镜像模式（默认，推荐）

```bash
docker compose up -d
```

- 直接拉 `ghcr.io/y-nanli/delivery-note-generator:latest`，容器内不含 git，启动即用；
- `Watchtower` 每 5 分钟检查镜像是否更新，有更新自动重启容器；
- 更新链路：`push Gitee → 镜像同步 GitHub（实测数秒）→ Actions 构建（30–60 秒）→ Watchtower（≤5 分钟）`；
- 看更新日志：`docker logs -f delivery-note-watchtower`；
- 想立刻重建：GitHub → Actions → build-image → Run workflow。

### 源码同步模式

```bash
# 把 .env 里 COMPOSE_PROFILES 改成 source，然后
docker compose up -d

# 或临时指定，不改 .env
docker compose --profile source up -d
```

- `alpine/git` 每 5 分钟 `git fetch` + `git reset --hard origin/master`，强制对齐远端，不产生冲突，nginx 无需重启；
- 先试 GitHub（经 `gh-proxy.com` 加速），失败自动回落 Gitee；两个源都不可用会在日志里报 `all sources failed`；
- 看同步状态：`docker logs -f delivery-note-sync`；
- 首次要求 `./htdocs` 目录为空，否则 clone 失败。

### 模式切换

```bash
# 停掉所有模式（两个 profile 都写上，避免另一模式的容器残留）
docker compose --profile image --profile source down
# 改 .env 里的 COMPOSE_PROFILES（image / source）
docker compose up -d         # 再起目标模式
```

### 共用注意

- 单据数据存在浏览器 localStorage，按访问地址隔离。从 `file://` 迁到 `http://NASIP:8088` 需用软件内的「导出备份 / 导入备份」搬一次；之后固定用同一地址访问，换 IP 或端口会变成另一份空库。
- 没有 `.env` 时 `docker compose up -d` 会报 `no service selected`，此时改用 `docker compose --profile image up -d`（源码模式同理换 `source`）。
- Docker 只托管网页，打印仍由连接打印机的那台电脑完成。
- 镜像当前为 public，匿名可拉。国内建议直接用镜像站前缀 `ghcr.nju.edu.cn/y-nanli/delivery-note-generator:latest`（飞牛的「加速源」只对 docker.io 生效，管不到 ghcr.io，详见 [部署说明.md](部署说明.md)）。若日后改成 private，NAS 上需先 `docker login`。
- 目前只构建 `linux/amd64`（绝大多数飞牛/x86 设备适用）；ARM 机型需要在 workflow 里加 `platforms: linux/arm64`。
- GHCR 拉取不顺时，在 GitHub 仓库加 `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN` 两个 secrets，Actions 会额外推到 Docker Hub，再把 `docker-compose.yml` 里的 `image` 换掉即可。
- Watchtower 只更新带 `com.centurylinklabs.watchtower.enable=true` 标签的容器，不会动 NAS 上别的服务。

## 注意

- 仅支持 Windows（启动脚本基于 PowerShell / bat）。
- 数据存于浏览器本地存储，清理浏览器数据会丢失单据，请定期导出备份。

## 版本

当前 `v1.23`（2026-11-25）：新增「货物明细记忆库」——按规格型号自动带出存货名称和单位，可单独导出/导入，老用户按存货编号存的商品库会自动迁移；其余为 v1.22 的编号前缀（XS/DB/TQ）、字号预设、表格铺底修复等。
