## トライ1

トライ1では下の様にラダーの論理回路をそのまま論理演算で記述できるところまで試しています。

```
y0 = x0
y1 = (x1 || y1) && !x2
```

### 構成

Rubyで書いたプログラムをMac Book Proで実行しPLCを制御し、PLCの入出力の操作、モニターをirBoardで行います。  
ここでは Mac Book Proを使いましたが、WindowsやLinux、Raspberry PIに置き換える事ができます。(実際の確認はまだしてません)

![構成図](https://i.gyazo.com/77556d1a56d8bb74a9b757265de93ad9.png)

### 試し方

- このプロジェクトの[トップ画面](https://github.com/ito-soft-design/thought_of_ladder_to_ruby)の右側にある ___Clone or download___ ボタンでダウンロードしてください。
- 圧縮を展開し、その中のtry1ディレクトリに移動します。  
  [try1ディレクトリ](https://github.com/ito-soft-design/thought_of_ladder_to_ruby/tree/master/try1)

- PLCプロジェクト try1.gxw をGXWorks2でPLCに書き込みます。  
  PCパラメータの内臓Ethernetポート設定タブを選択し、IPアドレスを必要に応じて変更します。    
  ここではGoogle WiFiを使用し 192.168.86.10 で設定する前提で説明します。

  ![IP設定](https://i.gyazo.com/e60814b2b3e8518538f7aaac467b8387.png)

- Rubyを実行できる環境を準備してください。
  - Rubyの公式サイトに[インストールについて](https://www.ruby-lang.org/ja/documentation/installation/)のページがありますが、下の検索から分かりやすいのを見つけてください。  
  [ruby install qiita の検索結果](https://www.google.com/search?client=safari&rls=en&ei=kZHDXMrzNsaD8wX-qrOwDg&q=ruby+install+qiita&oq=ruby+install+qiita&gs_l=psy-ab.3...1286.6932..7335...6.0..0.111.1016.6j4......0....1..gws-wiz.......0i71j0j0i8i4i30j33i160j0i8i30j0i203j0i4i30j0i30j33i21.pXAJHawhwyE)
  - Rubyのバージョンは2.3.3以上にしてください。

  - ターミナルを起動し、try1のディレクトリに移動します。
  (your_download_dirはダウンロード先のパスに置き換えてください。)  

  ```
  $ cd your_download_dir/try1
  ```

- ```bundle``` コマンドを実行します。

  ```
  $ bundle
  ```

- ```config/connection.yml``` を作成します。

  config/connection.ymlに接続先PLCのIPアドレスなど設定します。  
  現在の対応は MC Protocol のみで、三菱電機製を対象としています。  
  他のメーカーの場合は MC Protocol で接続できる様に設定してください。  

  ```
  $ cp config/connection.yml.sample config/connection.yml
  ```

  テキストエディターなどでconfig/connection.ymlのhostに接続するPLCのIPアドレスを設定します。

  ```
  plc:
    # MITSUBISHI iQ-R
    cpu: iq-r
    protocol: mc_protocol
    host: 192.168.86.10      # ここをPLCのIPアドレスに合わせて設定
    port: 5010
  ```
- Mac Book ProをPLCと接続できる様にネットワーク設定をします。  
  通常はGoogle WiFiのネットワークに接続するだけでいいはずです。

- sequence_1.rbを実行します。

  ターミナルでsequence_1.rbを実行します。  

  ```
  $ ruby sequence_1.rb
       user     system      total        real
   0.000500   0.000304   0.000804 (  0.001214)
  ```

  一応どのくらい時間がかかるのかサイクルタイムを表示する様にしてみました。totalがサイクルタイムになります。  

  sequence_1.rbの中身は上の例そのままです。

  ```
  require './plc_base'

  sequence do |plc|
    plc.y0 = plc.x0
    plc.y1 = (plc.x1 || plc.y1) && !plc.x2
  end
  ```

  但し、X、Yデバイスだと実際に配線しないと確認できないので、plc_base.rb内でBデバイスに変換して、タッチパネルで確認する様に細工しています。  

| 変換前 | 変換後 |
|:--|:--|
|X0-XFFF|B0-BFFF|
|Y0-YFFF|B1000-B1FFF|


- irBoardで動作確認してみます。

  irBoardは、iOSデバイスで動作するPLC向けのタッチパネルアプリです。  
  無料の[irBoard Lite](https://itunes.apple.com/jp/app/irboard-lite/id432058811?mt=8)がありますので、これで試してみます。  

  irBoard LiteをインストールしたiPadのSafariで下のリンクを開きます。  
  https://github.com/ito-soft-design/thought_of_ladder_to_ruby/raw/master/try1/try1.irboard

  irBoard Liteで開くが表示されます。  
  それを押すとirBoard Liteにプロジェクトがインポートされます。

  ![](https://i.gyazo.com/7ea1b94a3ac3d6c9438a062cd1c8f625.png)

  プロジェクト一覧からProject2を選択します。

  ![](https://i.gyazo.com/5b5bfe7c8b3e2d01911c33a4e52140d1.png)

  PLCに設定したIPアドレスをIPまたはホスト名に設定します。

  ![](https://i.gyazo.com/46c37a8585e2c63d6c61cc31ad8c98f6.png)

  右上の▶︎を押すと実行できます。
  意図した様に動作する事が確認できます。

  ![](https://i.gyazo.com/f7125b584b09af955e50594bb1acd3ed.png)

  irBoard Liteは最初に接続が確立した時間から60分間接続する事が可能です。  
  10:00に接続確立したら11:00まで接続できます。  
  11:00を過ぎるとPLCと接続することはできなくなります。  
  制限なく利用したい場合は有料版をご検討ください。

### デモ動画

[![](https://img.youtube.com/vi/phHdJCKn37I/0.jpg)](https://www.youtube.com/watch?v=phHdJCKn37I)
