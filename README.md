# dockerPhoenix
フロントエンドをelm バックエンドのAPIをElixir
データベースをMysqlとして起動します。

## Dockerのビルド
```
docker-compose build
```

### PhoenixProject作成
```
docker-compose run app mix phx.new . --app api --no-html --database mysql
```

### 追加（Login機能を入れる場合用)

```mix.ex
  defp deps do
    [
      # 省略・・・
      {:guardian, "~> 1.0"},
      {:guardian_db, "~> 1.0"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 0.12"}
    ]
```
#### ライブラリインストール
```
docker-compose run app mix deps.get
```
参考記事
Phoenix/ElixirでAPIのログイン機能を作成する(guardian・guardianDB) https://qiita.com/yujikawa/items/fe262eb98c5be713d8fb

### DB Migrate
```
docker-compose run app mix ecto.create
```
参考にした記事
Phoenix 公式
https://hexdocs.pm/phoenix/overview.html

DockerでPhoenix Framework https://qiita.com/foxtrackjp/items/bc74f64eae3ce33c8125
(DockerFileなどほぼそのまま)

elm 0.19 で JSONを使ってjsと通信したメモ https://qiita.com/hibohiboo/items/33a8dcf462bd8e4a55e0

