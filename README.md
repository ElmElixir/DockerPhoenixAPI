# dockerElmPhoenix
フロントエンドをelm バックエンドのAPIをElixir
データベースをMysqlとして起動します。

## docker compose ファイル
MySQL8.0以降はまだ対応していない？そのため5.7にしています。

mariaex error #222

https://github.com/xerions/mariaex/issues/222
```
version: '3'
services:
  db:
    image: mysql:5.7
    container_name: 'dev_db'
    ports:
      - '3306:3306'
    volumes:
      - ./mysql/volumes:/var/lib/mysql
    environment:
      MYSQL_ROOT_USERNAME: 'root'
      MYSQL_ROOT_PASSWORD: 'password'
      MYSQL_HOSTNAME: 'localhost'     
  app:
    build: ./
    container_name: 'web_app'
    working_dir: /opt/app
    volumes:
      - .:/opt/app
      - ./web:/opt/app/web
    environment:
      MYSQL_ROOT_USERNAME: 'root'
      MYSQL_ROOT_PASSWORD: 'password'
      MYSQL_HOSTNAME: 'localhost'
      MYSQL_PORT: '3306'
    ports:
      - '3000:3000'
      - '4000:4000'
      - '8000:8000'
    tty: true
    depends_on:
      - db
```
## Dockerのビルド
バックグラウンドのAPIを作成するため、Phoenixを立ち上げます。
```
docker-compose build
```

### MySQLコンテナ起動
DBを起動させます
`-d`を入れてバックグランドで動かします。
```
docker-compose up -d db
```
### PhoenixProject作成
デフォルトはpostgreSQLであるためここではMySQLで起動します。
（特に理由はないですがポスグレの場合はDocker-Compose.ymlをポスグレに修正してください）
API機能のみなのでほかのHTML生成はなし
```
 docker-compose run --rm app mix phx.new . --database mysql --no-html --no-brunch
```
#### ライブラリ追加
adapter の` {:plug_cowboy, "~> 1.0"},`を追加　

config/mix.exs内へ追加
```
[中略]
  defp deps do
    [
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:mariaex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 1.0"},　#ココ
      {:cowboy, "~> 1.0"}
    ]
  end
  
[中略]
```
#### ライブラリインストール
Elixirライブラリをインストールします。
```
docker-compose run --rm app mix deps.get
```

#### 開発環境のDB接続準備
\config\dev.exs の書き換え
```
[中略]
# Configure your database
config :app, App.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "password",
  database: "app_dev",
  hostname: "db",
  pool_size: 10
[中略]

```

### DB Migrate
DB情報を更新
```
docker-compose run --rm app mix ecto.create
```
# Phoenixを起動する。
アプリを起動します。
```
docker-compose run --rm app mix phx.server
```
`http://localhost:4000` でPhoenixの画面でルーティングのエラーメッセージが出ればOKです。後ほどElm側でルーティングします。
止める場合は `Ctl + C` でPhoenixを停止できます。

### Elixirバージョン確認
```
docker-compose run --rm app elixir -v
```
### Phoenix バージョン確認
```
docker-compose run --rm app mix phx.new --version
```


## Dockerコンテナ内へ入って作業
注意：一応`docker ps` などで確認してくんさい
docker-compose ファイルで設定した`container_name: "web_app"`を指定していますので container name でDocker内に入ります。

```
docker exec -it web_app //bin/sh
```
これでDockerのコンテナ内に入れました。
以降はDocker内の作業です。

### elm の設定
 cd web/
 にてElm用のディレクトリに移動します。

```
docker-compose run --rm web elm init
```
`/opt/app/web # elm reactor`
すると
Go to <http://localhost:8000> to see your project dashboard.
ダッシュボードが http://localhost:8000 に表示されます

## 作業終了時
Dockerコンテナから離脱します。
```
exit
```
Dockerコンテナを停止します。
```
docker-compose down
```

悩んでるところは docker-compose up -d で mix phx.server と elm reactor を同時に動かしたいんですけれどもどうしよコンテナ分けるなど簡単にしたい。

# 参考にしたページ
## Docker の設定
 - Elixir/Phoenix+MySQL5.7環境をDocker/Docker Composeで整え開発する。
  https://qiita.com/studio23c/items/510a12abd53f3651b5b2
 - Elixir1.6 / Phoenix1.3の環境をDockerで整えてCRUDアプリを動かすまで
  https://qiita.com/dd511805/items/13f3ea4255dc4d1a3fbb 
## Elixir Phoenix
Phoenix 公式
https://hexdocs.pm/phoenix/overview.html

## elm
 - Create Elm App 
  https://github.com/halfzebra/create-elm-app#getting-started
 - Elmで非同期Http通信を含んだSPAを試してみる
  https://qiita.com/sand/items/849c919b0d957ee99b9d
 - elm 0.19 で JSONを使ってjsと通信したメモ
  https://qiita.com/hibohiboo/items/33a8dcf462bd8e4a55e0
 - elm-lang examples
  https://elm-lang.org/examples
