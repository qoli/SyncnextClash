# Syncnext 規則集

這個 repository 使用版本化的本地規則協議，同一份 canonical 規則會生成
Mihomo/Clash、Stash、Surge、Loon、Shadowrocket、Quantumult X、sing-box 和
Passwall 產物。

請勿直接修改生成檔。規則維護入口只有：

- [`rulesets/proxy.yaml`](rulesets/proxy.yaml)：應使用代理的規則。
- [`rulesets/unbreak.yaml`](rulesets/unbreak.yaml)：應直接連線的規則。

協議和 Passwall 顯式展開格式見 [`rulesets/README.md`](rulesets/README.md)。

## Clash / Mihomo / Stash

為相容既有使用者，兩個 URL 保持不變：

- SyncnextProxy：<https://raw.githubusercontent.com/qoli/SyncnextClash/main/proxy-classical.yaml>
- SyncnextUnbreak：<https://raw.githubusercontent.com/qoli/SyncnextClash/main/Unbreak-classical.yaml>

兩份檔案均為 `behavior: classical` 的 rule-provider payload。Mihomo/Stash
使用者在自己的設定內把 SyncnextProxy 綁到代理策略、SyncnextUnbreak 綁到
`DIRECT`。

## 其他 App 產物

其他生成檔發布於 `generated` 分支：

| App / 核心 | Proxy | Unbreak |
| --- | --- | --- |
| Mihomo | [`mihomo/proxy-classical.yaml`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/mihomo/proxy-classical.yaml) | [`mihomo/Unbreak-classical.yaml`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/mihomo/Unbreak-classical.yaml) |
| Stash | [`stash/proxy-classical.yaml`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/stash/proxy-classical.yaml) | [`stash/Unbreak-classical.yaml`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/stash/Unbreak-classical.yaml) |
| Surge | [`surge/proxy.list`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/surge/proxy.list) | [`surge/unbreak.list`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/surge/unbreak.list) |
| Loon | [`loon/proxy.list`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/loon/proxy.list) | [`loon/unbreak.list`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/loon/unbreak.list) |
| Shadowrocket | [`shadowrocket/proxy.list`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/shadowrocket/proxy.list) | [`shadowrocket/unbreak.list`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/shadowrocket/unbreak.list) |
| Quantumult X | [`quantumult-x/proxy.list`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/quantumult-x/proxy.list) | [`quantumult-x/unbreak.list`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/quantumult-x/unbreak.list) |
| sing-box JSON | [`sing-box/proxy.json`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/sing-box/proxy.json) | [`sing-box/unbreak.json`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/sing-box/unbreak.json) |
| sing-box SRS | [`sing-box/proxy.srs`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/sing-box/proxy.srs) | [`sing-box/unbreak.srs`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/sing-box/unbreak.srs) |

Surge、Loon 和 Shadowrocket 的遠端 rule-set 不含策略名稱，策略由 App 的引用
設定決定。Quantumult X 產物已分別帶有 `proxy` 和 `direct`，仍可在
`filter_remote` 使用 `force-policy` 覆蓋。

sing-box 可直接引用 JSON source 或 SRS binary，例如：

```json
{
  "type": "remote",
  "tag": "syncnext-proxy",
  "format": "binary",
  "url": "https://raw.githubusercontent.com/qoli/SyncnextClash/generated/sing-box/proxy.srs"
}
```

## Passwall

Passwall 的 domain 與 IP 必須分別匯入：

- [`proxy_host`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/passwall/proxy_host)
- [`proxy_ip`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/passwall/proxy_ip)
- [`direct_host`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/passwall/direct_host)
- [`direct_ip`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/passwall/direct_ip)

舊 `main/passwall/*` 手工清單已停止使用；其中只存在於 Passwall、未存在於兩份
原 Clash 權威檔案的歷史規則沒有遷入新協議。

## 本地維護

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.lock
./scripts/install_ci_sing_box.sh .venv/bin
.venv/bin/python tools/rules.py validate
.venv/bin/python -m unittest discover -s tests -v
.venv/bin/python tools/rules.py generate --sing-box .venv/bin/sing-box --output output
```

安裝腳本供 Linux amd64 CI 與 macOS arm64 本機共用，從
[官方 v1.13.15 release](https://github.com/SagerNet/sing-box/releases/tag/v1.13.15)
下載對應平台的 archive，使用固定 SHA-256 校驗後才安裝，並清理暫存下載。
本機不需設定 `RUNNER_TEMP`；其他平台會明確失敗。

完整生成需要準確的 `sing-box v1.13.15`，可用 `--sing-box` 指定路徑或由 PATH
尋找；版本缺失或不符會直接失敗。生成器會編譯兩份 SRS，再反編譯核對規則
語義。`check-generated` 可檢查 main 根目錄的兩份相容產物：

```bash
.venv/bin/python tools/rules.py check-generated
```

Pull request CI 會驗證協議、測試所有 adapter 並上傳 preview。合併至 main 後，
發布 workflow 會更新兩份相容 Clash 檔並發布完整 `generated` 分支。

目前 proprietary App 產物已通過格式與 golden tests，尚未逐 App 完成人工匯入
驗證。每次發布的來源 commit、規則數和 SHA-256 可在
[`manifest.json`](https://raw.githubusercontent.com/qoli/SyncnextClash/generated/manifest.json)
核對。
