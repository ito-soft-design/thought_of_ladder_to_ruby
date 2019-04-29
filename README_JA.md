# ラダーからRubyへの置き換えについての考察

ラダー回路をRubyプログラムに置き換える場合について検討していきます。
経緯は私のDiaryの方をご覧ください。

[一往確認日記 thought of ladder to ruby](http://diary.itosoft.com/?category=thought_of_ladder_to_ruby)

## トライ1

トライ1では下の様にラダーの論理回路をそのまま論理演算で記述できるところまで試しています。

```
y0 = x0
y1 = (x1 || y1) && !x2
```

### 試し方

- PLCプロジェクト try1.gxw をPLCに書き込みます。  
  PCパラメータ内臓Ethernetポート設定のIPアドレスを必要に応じて変更してください  
  ここではGoogle WiFiを使用し 192.168.86.10 で設定する前提で説明します。

  ![IP設定](https://i.gyazo.com/e60814b2b3e8518538f7aaac467b8387.png)

- Rubyを実行できる環境を準備してください。
  - Rubyの公式サイトに[インストールについて](https://www.ruby-lang.org/ja/documentation/installation/)ありますが、下の検索から分かりやすいのを見つけてください。  
  [ruby install qiita の検索結果](https://www.google.com/search?client=safari&rls=en&ei=kZHDXMrzNsaD8wX-qrOwDg&q=ruby+install+qiita&oq=ruby+install+qiita&gs_l=psy-ab.3...1286.6932..7335...6.0..0.111.1016.6j4......0....1..gws-wiz.......0i71j0j0i8i4i30j33i160j0i8i30j0i203j0i4i30j0i30j33i21.pXAJHawhwyE)
  - Rubyのバージョンは2.3.3以上にしてください。

- このサイトの右側にある ___Clone or download___ ボタンでダウンロードしてください。
- 圧縮を展開し、その中のtry1ディレクトリに移動します。  
  (your_download_dirはダウンロード先のパスに置き換えてください。)  
  [try1ディレクトリ](https://github.com/ito-soft-design/thought_of_ladder_to_ruby/tree/master/try1)

  ```
  $ cd your_download_dir/try1
  ```

- ```bundle``` を実行します。

  ```
  $ bundle
  ```

- ```config/connection.yml``` を作成します。

  config/connection.ymlに接続先PLCのIPアドレスなど設定します。  
  現在の対応はは MC Protocol のみで、三菱電機製を対象としています。  
  他のメーカーの場合は MC Protocol で接続できる様に設定してください。  

  ```
  $ cp config/connection.yml.sample config/connection.yml
  ```

  config/connection.ymlのhostに接続するPLCのIPアドレスを設定します。

  ```
  plc:
    # MITSUBISHI iQ-R
    cpu: iq-r
    protocol: mc_protocol
    host: 192.168.86.10      # ここをPLCのIPアドレスに合わせて設定
    port: 5010
  ```

- sequence_1.rbを実行します。

  サイクルタイムを表示する様にしてみました。totalがサイクルタイムになります。

  ```
  $ ruby sequence_1.rb
       user     system      total        real
   0.000500   0.000304   0.000804 (  0.001214)
  ```

  sequence_1.rbの中身は上の例そのままです。

  ```
  y0 = x0
  y1 = (x1 || y1) && !x2
  ```

  但し、X、Yだと配線しないと確認できないので、plc_base.rb内゛でBデバイスに変換しています。  

| 変換前 | 変換後 |
|:--|:--|
|X0-XFFF|B0-BFFF|
|Y0-YFFF|B1000-B1FFF|


- irBoardで動作確認してみます。

  irBoardはiPadで動作するPLCと接続して操作できるタッチパネルです。  
  無料の[irBoard Lite](https://itunes.apple.com/jp/app/irboard-lite/id432058811?mt=8)がありますので、これで試してみます。  

  iPadのSafariで下のリンクを開きます。  
  https://github.com/ito-soft-design/thought_of_ladder_to_ruby/raw/master/try1/try1.irboard
