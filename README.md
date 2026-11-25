# 送货单生成器 (delivery-note-generator)

按「开异模板」送货单格式录入、打印送货单的本地小工具。单文件 HTML + 启动脚本，无需安装、无需联网，数据保存在本机浏览器中。

## 特点

- 版式适配：Epson LQ-630KII 针式打印机 + 241×140mm 三联纸（默认版式），同时保留 A4 版式，可激光/喷墨打印或存 PDF。
- 单据管理：新建 / 保存 / 复制本单 / 打印；单据编号自动生成 `XS-日期-流水号`（如 `XS-2026-11-25-00003`），也可手动填写。
- 备份迁移：支持「导出备份 / 导入备份」，换电脑时迁移单据记录。
- 打印前实时预览，版式、页边距微调、三块字号均可调。

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
| `docker-compose.yml` | NAS 部署用，定时同步代码 + nginx 托管 |

## 快速开始

1. 双击 `启动送货单.bat`（Windows，依赖 PowerShell + Edge，无 Edge 时回退到默认浏览器）。
2. 首次使用请先给打印机建 241×140mm 纸张，步骤见 `使用说明.txt` 第三节。
3. 单据记录保存在本机浏览器里，换电脑请用软件内的「导出备份 / 导入备份」迁移，不要只拷 html 文件。

## Docker 部署（fnOS / 群晖等 NAS）

仓库自带 `docker-compose.yml`，用两个官方镜像：`alpine/git` 定时同步代码，`nginx:alpine` 提供网页，无需构建。

```bash
# 在 NAS 上建一个空目录
mkdir -p /vol1/1000/docker/delivery-note && cd /vol1/1000/docker/delivery-note
# 放入 docker-compose.yml 后启动
docker compose up -d
```

访问 `http://NAS的IP:8088`，`index.html` 会自动跳到 `送货单.html`。

同步机制：

- 每 5 分钟 `git fetch` + `git reset --hard origin/master`，强制对齐远端，不产生冲突，nginx 无需重启；
- 先试 GitHub（经 `gh-proxy.com` 加速），失败自动回落 Gitee；两个源都不可用会在日志里报 `all sources failed`；
- 查看同步状态：`docker logs -f delivery-note-sync`。

注意：

- 单据数据存在浏览器 localStorage，按访问地址隔离。从 `file://` 迁到 `http://NASIP:8088` 需用软件内的「导出备份 / 导入备份」搬一次；之后固定用同一地址访问，换 IP 或端口会变成另一份空库。
- Docker 只托管网页，打印仍由连接打印机的那台电脑完成。

## 注意

- 仅支持 Windows（启动脚本基于 PowerShell / bat）。
- 数据存于浏览器本地存储，清理浏览器数据会丢失单据，请定期导出备份。

## 版本

当前 `v1.19`（2026-11-25）。
