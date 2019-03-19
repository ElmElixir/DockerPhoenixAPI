# dockerPhoenix
フロントエンドをelm バックエンドのAPIをElixir
データベースをMysqlとして起動します。

## Dockerのビルド
```
docker-compose build
```
```
docker-compose run app mix phx.new . --app api --no-html --database mysql
```
```
docker-compose run app mix deps.get
```
```
docker-compose run app mix ecto.create
```
参考にした記事

DockerでPhoenix Framework https://qiita.com/foxtrackjp/items/bc74f64eae3ce33c8125
(DockerFileなどほぼそのまま)

elm 0.19 で JSONを使ってjsと通信したメモ https://qiita.com/hibohiboo/items/33a8dcf462bd8e4a55e0 #Qiita