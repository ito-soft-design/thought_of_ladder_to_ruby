# ラダーからRubyへの置き換えについての考察

ラダー回路をRubyプログラムに置き換える場合について検討していきます。
経緯は私のDiaryの方をご覧ください。

[一往確認日記 thought of ladder to ruby](http://diary.itosoft.com/?category=thought_of_ladder_to_ruby)


この内容は[トライ1](https://github.com/ito-soft-design/thought_of_ladder_to_ruby/blob/master/doc/try1.md)の続きになっています。環境の構築などはトライ1をご覧ください。

## トライ2

トライ2ではシリンダーセンサーなどのまとまった動作をオブジェクトとして表現します。

### 初期化

setupブロックでソレノイドオブジェクトとシリンダーセンサーオブジェクトを生成しています。

```
setup do |plc|
  sol = SingleSolenoid.new out:plc.dev.y0
  plc.add_device sol:sol
  cyl_sen = CylinderSensor.new solenoid:sol, moved_sensor:plc.dev.x2, org_sensor:plc.dev.x3, timeout:3.0
  plc.add_device cyl_sen:cyl_sen
end
```

シングルソレノイドを表す[SingleSolenoidクラス](https://github.com/ito-soft-design/thought_of_ladder_to_ruby/blob/master/try2/single_solenoid.rb)と、シリンダーセンサーを表す[CylinderSensorクラス](https://github.com/ito-soft-design/thought_of_ladder_to_ruby/blob/master/try2/cylinder_sensor.rb)を準備しました。  

```sol = SingleSolenoid.new out:plc.dev.y0``` でシングルソレノイドのオブジェクトを生成していて、y0を出力として定義しています。  

```cyl_sen = CylinderSensor.new solenoid:sol, moved_sensor:plc.dev.x2, org_sensor:plc.dev.x3, timeout:3.0``` でシリンダーセンサーのオブジェクトを生成しています。  
X2が動作端のセンサーでX3が戻り端のセンサーでエラーを検出する時間を3秒としています。


```plc.add_device``` でこれらのデバイスを後でplc.solやplc.cly_senで扱える様にデバイス登録しています。

### 制御処理

制御内容は前回同様sequenceブロックに書きます。

```
sequence do |plc|
  plc.sol = (plc.x0 || plc.sol) && !plc.x1
  plc.m0 = plc.dev.cyl_sen.moved?
  plc.m1 = plc.dev.cyl_sen.returned?
  plc.m2 = plc.dev.cyl_sen.error?
end
```

```plc.sol = (plc.x0 || plc.sol) && !plc.x1``` はtry1の自己保持がplc.solとして書かれているだけです。  
x0でソレノイド出力Y0がONになりx1でOFFになります。  

```plc.m0 = plc.dev.cyl_sen.moved?``` ではセンサーの状態をM0等に代入しています。

### 確認

前回同様にirBoardで動作確認してみます。

今回はこのファイルをirBoard Liteにインポートします。  
インポートの仕方は[try1の説明](https://github.com/ito-soft-design/thought_of_ladder_to_ruby/blob/master/doc/try1.md)をご覧ください。

https://github.com/ito-soft-design/thought_of_ladder_to_ruby/raw/master/try2/try2.irboard


PLCのプロジェクトはtry1のままで構いません。

実際にはシリンダーを動かしているわけではないので、L0がONの時にY0がON/OFFするのに合わせてX2、X3が動く様に仕掛けを入れています。  
L0がOFFならX2、X3が追従しないのでシリンダーエラーが発生します。  

```
setup do
  # for simulation
  plc.add_device t_on:Timer.new(1)
  plc.add_device t_off:Timer.new(1)
  plc.l0 = true
end
```

```
sequence do
  # for simulation
  if plc.l0 == true
    plc.t_on = plc.sol
    plc.t_off = !plc.sol
    plc.x2 = plc.t_on
    plc.x3 = plc.t_off
  end
end
```


### デモ動画

[![](https://img.youtube.com/vi/twSw8mvOS8U/0.jpg)](https://www.youtube.com/watch?v=twSw8mvOS8U)
