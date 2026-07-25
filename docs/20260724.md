## 2026-07-24

### 問題
- `fvm flutter run` でAndroidエミュレータ実行時に以下のエラーが継続発生
  `Error connecting to the service protocol: failed to connect to http://127.0.0.1:xxxxx/`
- ビルド・APKインストールは成功するが、デバッグ接続だけ失敗
- iOSシミュレータでは同じコードが問題なく動作 → Android固有の問題と判明

### 試したが効果がなかった対処
- ファイアウォールの無効化
- adbのkill-server / start-server
- flutter clean
- プロキシ環境変数の確認(該当なし)
- ポートフォワーディングの再設定

### 根本原因
- Androidエミュレータ自体が正常に起動しきれておらず、画面が真っ黒な状態のまま
  (Apple Silicon Mac特有のグラフィックレンダリング起動不良と思われる)
- 見た目はエミュレータが起動しているように見えても、内部のDartVM/デバッグサービスが
  正しく立ち上がっていなかった可能性

### 解決方法
- Android Studio > Device Manager > 該当エミュレータの「Cold Boot Now」を実行
- スナップショットを使わず完全に最初から起動し直すことで、正常にホーム画面が表示され、
  `flutter run` の接続エラーも解消

### 学び
- エミュレータの画面が黒いまま/固まっている場合、通常の再起動ではなくCold Bootを試す
- 「ビルド・インストールは成功するのにデバッグ接続だけ失敗する」パターンは、
  エミュレータ自体の起動不良を疑うと切り分けが早い
